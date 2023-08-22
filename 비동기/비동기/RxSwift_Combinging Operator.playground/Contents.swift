import Foundation
import RxSwift

// MARK: - Combinging Operator

let disposeBags = DisposeBag()

// startWith : Observable 시퀀스에 초기값을 앞에 붙임
let coStartWith = Observable.of("A", "B", "C")

coStartWith
    .startWith("Keyboard")
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

// concat : 같은 데이터 타입의 요소를 갖는 두 개의 Observable들을 묶을 때 사용
let iPhonSeries = Observable<String>.of("iPhone12", "iPhone13", "iPhone14")
let appleNaming = Observable<String>.of("Apple")

let title = Observable.concat([appleNaming, iPhonSeries])

// title 사용 o - 출력 결과는 똑같다.
title
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

// title 사용 x - 출력 결과는 똑같다.
appleNaming
    .concat(iPhonSeries)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

// concatMap : 각각의 시퀀스가 다음 시퀀스가 구독되기 전에 합쳐짐을 보증
let school: [String: Observable<String>] = [
    "1반": Observable.of("Student1", "Student2", "Student3"),
    "2반": Observable.of("Student4", "Student5")
]

let classes = Observable.of("Class1", "Class2")
classes
    .concatMap { classes in
        school[classes] ?? .empty()
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

// merge : sequence들을 합치는 방법 중 하나
let firstName = Observable.from(["김", "이", "박", "홍", "조"])
let lastName = Observable.from(["씨", "비", "리", "팍", "침"])

Observable.of(firstName, lastName) // 순서를 보장하지 않고 로그가 찍힘
    .merge()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

/*
 maxConcurrent는 인자의 수만큼 옵저버블의 이벤트를 받을 수 있습니다.
 아래와 같이 merge하는 옵저버블은 3개인데 mexConcurrent에는 2개만 merge 하도록하면
 subjectC에서 이벤트가 발생해도 next 이벤트를 방출하지 않습니다.
 하지만 앞서 merge 된 subjectA, subjectB둘중 하나라도 Completed된다면 subjectC는 이벤트를
  받을 수 있습니다.

  */

let subjectA = BehaviorSubject(value: "A")
let subjectB = BehaviorSubject(value: "B")
let subjectC = BehaviorSubject(value: "C")

let mergeConcurrentObservable = Observable.of(subjectA, subjectB)
mergeConcurrentObservable
    .merge(maxConcurrent: 2) // maxConcurrent: 한 번에 받아낼 Observable의 수
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBags)

subjectC.onNext("C")
subjectA.onNext("A")
subjectA.onCompleted()
subjectC.onNext("C")

// combineLatest : combine(결합)된 Observable들은 값을 방출할 때마다, 제공한 클로저를 호출하며 우리는 각각의 내부 Observable들의 최종값을 받음

// 여러 TextFidld를 한 번에 관찰하고, 값을 결합하거나 여러 상태 관찰 예시
let firstNameTextField = PublishSubject<String>()
let lastNameTextField = PublishSubject<String>()

let userName = Observable.combineLatest(firstNameTextField, lastNameTextField) { firstName, lastName in
    firstName + lastName
}

userName
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

firstNameTextField.onNext("Wayne")
lastNameTextField.onNext("Micheal")
lastNameTextField.onNext("Bruce")

// 날짜 입력 값 받는 예시

let dateFormat = Observable<DateFormatter.Style>.of(.short, .long)
let nowDate = Observable<Date>.of(Date())

let showNowDate = Observable.combineLatest(dateFormat, nowDate, resultSelector: {
    _, date -> String in
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/mm/dd"
    return dateFormatter.string(from: date)
})

nowDate.subscribe(onNext: {
    print($0)
})
.disposed(by: disposeBags)

// zip : 결합을 원하는 각각의 시퀀스들의 요소들을 순차적으로 결합함
// 둘 중 하나의 Observable이 완료되면 zip에 대한 Observable은 종료함.

enum GameReuslt {
    case Win
    case Lose
}

let gameMatch = Observable<GameReuslt>.of(.Win, .Win, .Lose, .Win, .Lose)
let gamePlayer = Observable<String>.of("Korea", "America", "Germany", "Japan", "England")
let gameResult = Observable.zip(gameMatch, gamePlayer) { result, player in
    player + "Player" + " : \(result)"
}

gameResult
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

// withLatestFrom : withLatestFrom을 호출한 Observable은 onNext하면 withLatestFrom의 파라미터인 Observable의 최신값을 trigger 함

let startSign = PublishSubject<Void>()
let runningPlayer = PublishSubject<String>()

startSign
    .withLatestFrom(runningPlayer)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

runningPlayer.onNext("1")
runningPlayer.onNext("2")
runningPlayer.onNext("3")

startSign.onNext(())
startSign.onNext(())

// sample : withLatestFrom 처럼 trigger 역할을 하지만 단 한번만 trigger함
let f1Player = PublishSubject<String>()

f1Player
    .sample(startSign)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

f1Player.onNext("car1")
f1Player.onNext("car2")

startSign.onNext(())

// amb : 두 가지 시퀀스를 받을 때, 두 가지 시퀀스 중 어떤 것을 구독할 지 애매모호할 때 사용하는 방식이라는데, amb에 대한 두 가지 Observable 중 먼저 element를 방출하는 Observable만 구독하고 나머지 ObserVable은 무시됨.

let bus726 = PublishSubject<String>()
let bus937 = PublishSubject<String>()

let busStation = bus726.amb(bus937)

busStation
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)
bus937.onNext("버스937-승객0: 사람1")
bus726.onNext("버스726-승객0: 사람2")
bus726.onNext("버스726-승객1: 사람3")
bus937.onNext("버스937-승객1: 사람4")
bus726.onNext("버스726-승객2: 사람5")
bus937.onNext("버스937-승객2: 사람6")

// switchLatest : SourceObservable로 들어온 마지막 시퀀스만 구독하는 방식

let student1 = PublishSubject<String>()
let student2 = PublishSubject<String>()
let student3 = PublishSubject<String>()

let handUp = PublishSubject<Observable<String>>() // SourceObservable

let handUpClass = handUp.switchLatest()

handUpClass
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

handUp.onNext(student1)
student1.onNext("학생1 : 저는 1번 학생입니다.")
student2.onNext("학생2: 저요 저요!!!") // 출력 무시됨

handUp.onNext(student2)
student2.onNext("학생2: 저는 2번이에요!")
student1.onNext("학생1: 아.. 나 아직 할말 있는데") // 출력 무시됨

handUp.onNext(student3)
student2.onNext("학생2: 아니 잠깐만! 내가!") // 출력 무시됨
student1.onNext("학생1: 언제 말할 수 있죠") // 출력 무시됨
student3.onNext("학생3: 저는 3번 입니다~ 아무래도 제가 이긴 것 같네요.")

handUp.onNext(student1)
student1.onNext("학생1: 아니, 틀렸어, 승자는 나야.")
student2.onNext("학생2: ᅲᅲ") // 출력 무시됨
student3.onNext("학생3: 이긴 줄 알았는데") // 출력 무시됨
student2.onNext("학생2: 이거 이기고 지는 손들기였나요?") // 출력 무시됨

// reduce : 제공된 초기값(예제에서는 0)부터 시작해서 source observable이 값을 방출할 때마다 그 값을 가공함(swift 문법의 reduce와 동일)
let reduceObservable = Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
reduceObservable
    .reduce(0, accumulator: { summary, newValue in
        summary + newValue
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)

// scan : reduce의 경우, 결과값만을 방출하지만, scan은 매번 값이 들어올 때마다 결과값을 방출하게 됨.
let scanObservable = Observable.from([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
scanObservable
    .scan(0, accumulator: { summary, newValue in
        summary + newValue
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)
