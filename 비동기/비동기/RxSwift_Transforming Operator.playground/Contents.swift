import Foundation
import RxSwift

// MARK: - Transforming Operator

let disposeBags = DisposeBag()

// toArray : Observable의 독립적 요소들을 array로 만드는 연산자 (Singe<[T]> 형태로 변환됨)
let toArrayObservable = Observable.of("A", "B", "C")
toArrayObservable
    .toArray()
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBags)

// map : 요소를 원하는 타입의 데이터로 변환해주는 연산자
let mapObservable = Observable.of(Date())
mapObservable
    .map { date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// flatMap : Observable 내부의 Observable를 위상으로 평평하게 펼쳐주는 것
// 반환 과정은 Observable<Observable<T>>->Observable<T>
protocol PlayerProtocol {
    var count: BehaviorSubject<Int> { get }
}

struct Player: PlayerProtocol {
    var count: BehaviorSubject<Int>
}

let koreanPlayer = Player(count: BehaviorSubject<Int>(value: 10))
let americanPlayer = Player(count: BehaviorSubject<Int>(value: 8))

let olympic = PublishSubject<Player>()
olympic
    .flatMap { player in
        player.count
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

olympic.onNext(koreanPlayer)
koreanPlayer.count.onNext(10)
olympic.onNext(americanPlayer)
koreanPlayer.count.onNext(10)
americanPlayer.count.onNext(9)

/*
 출력 결과 해설 : BehaviorSubject는 초기값을 가지고 있는 Subject입니다.
 이벤트를 발행할 때, 초기값을 제일 먼저 발행합니다.
 그래서 한국선수의 초기값 10이 먼저 출력이 되고, 그 뒤로 한국 선수가 10점을
 획득한 이벤트를 출력합니다.
 그리고 미국 선수 역시 마찬가지로, 미국선수의 초기값이 출력이 된 다음 한국
 선수의 점수와 미국 선수의 점수 이벤트가 차례대로 출력이 됩니다.
 */

// flatMapLatest : 시퀀스 내부의 시퀀스 중 가장 최근에 전환된 시퀀스에서 나온 값만 반영
// Target observable의 결과값으로는 오직 최근의 observable에서 나온 값만 받게 된다.

struct SoccerPlayer: PlayerProtocol {
    var count: BehaviorSubject<Int>
}

let engliand = SoccerPlayer(count: BehaviorSubject(value: 0))
let germany = SoccerPlayer(count: BehaviorSubject(value: 1))

let worldCup = PublishSubject<PlayerProtocol>()

worldCup
    .flatMapLatest { player in // 가장 최신 시퀀스만 반영
        player.count
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

worldCup.onNext(engliand) // 이 시점 최신 시퀀스
engliand.count.onNext(1)

worldCup.onNext(germany) // 이 시점 최신 시퀀스
engliand.count.onNext(2) //  잉글랜드 시퀀스
germany.count.onNext(2)

// meterialize : 단순히 요소만이 아니라 요소를 포함한 이벤트로 받음.
// dematerialize : 요소를 포함한 이벤트를 다시 요소로 받음.

enum Foul: Error {
    case offside
}

let koreanSoccerPlayer = SoccerPlayer(count: BehaviorSubject<Int>(value: 0))
let japanSoccerPlayer = SoccerPlayer(count: BehaviorSubject<Int>(value: 0))

let footballMatch = BehaviorSubject<PlayerProtocol>(value: koreanSoccerPlayer) // 시퀀스 내부 첫 시퀀스는 한국선수

footballMatch
    .flatMapLatest { player in
        player.count
            .materialize()
    }
    .filter {
        guard let error = $0.error else {
            return true
        }

        print(error)
        return false
    }
    .dematerialize()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

japanSoccerPlayer.count.onNext(1)
japanSoccerPlayer.count.onError(Foul.offside)

footballMatch.onNext(koreanSoccerPlayer)
koreanSoccerPlayer.count.onNext(1)
