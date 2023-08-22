import Foundation
import RxSwift

// MARK: - Subject

// Subject : Observable이자 Observer, 실시간으로 이벤트를 생성하고 구독함.

// PublishSubject : 빈 상태로 시작하여, subscribe 이후의 이벤트만을 subscriber를 통해 방출한다.

// BehaviorSubject : subscribe 직전의 하나의 이벤트를 포함한 채 subscribe 이후 이벤트들을 subscriber를 통해 방출한다.

// ReplaySubject : 버퍼를 두고 초기화하며, 버퍼 사이즈 만큼의 직전의 이벤트들을 포함한 채 subscribe 이후 이벤트들을 subscriber를 통해 방출한다.

// Varaible : BehaviorSubject를 래핑하고, 현재의 값을 상태로 보존, 가장 최신/초기 값만을 새로운 subscriber에게 방출

// Subject와 Relay의 차이점
// Subject는 .completed, .error의 이벤트가 발생하면 subscriber가 종료됨.
// Relay는 .completed, .error를 발생하지 않고 Dispose되기 전까지 계속 작동하기 때문에 UI Event에서 사용하기 적합

// MARK: - Filtering Operator

// ignoreElements : next 이벤트를 무시함, completed, error 같은 정지 이벤트는 허용
let disposeBags = DisposeBag()

let sleepingDogs = PublishSubject<String>()

sleepingDogs
    .ignoreElements()
    .subscribe { _ in
        print("햇빛")
    }
    .disposed(by: disposeBags)

// sleepingDogs 이벤트 생성
// onNext : Observable의 최신 값을 emit -> 무슨 뜻인지 기억 안 날거 같아서 메모해놓음.
sleepingDogs.onNext("Kill 1")
sleepingDogs.onNext("Kill 2")
sleepingDogs.onNext("Kill 3")

// elementAt : 특정 인덱스에 해당하는 요소만 방출함, 나머지는 무시함
let alarm = PublishSubject<String>()

alarm
    .element(at: 2)
//    .element(at: 4)// 지금 현재 인덱스는 3까지만 있는데 여기서 인덱스 4를 방출하겠다하면, 해당 요소가 없기에 무시함.
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

alarm.onNext("1") // 인덱스 0
alarm.onNext("2") // 인덱스 1
alarm.onNext("3") // 인덱스 2 -> 여기만 방출
alarm.onNext("4") // 인덱스 3

// filter : Bool 데이터 타입의 파라미터(Bool 값을 리턴하는 클로저)에 따라 true인 이벤트만 방출
let observableFilter = Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
observableFilter
    .filter { $0 % 2 == 0 }
    .subscribe(onNext: {
        print($0) // 2 4 6 8 만 로그 찍힘
    })
    .disposed(by: disposeBags)
