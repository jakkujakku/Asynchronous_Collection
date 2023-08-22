import Foundation
import RxSwift

// RxSwift 튜토리얼

/*
 Rx코드의 기반이 심장
 T형태의 데이터 snapshot을 '전달'할 수 있는 일련의 이벤트를 비동기적으로 생성하는 기능
 Observabel = Observable Sequence = Sequence
 비동기적(asynchronous)
 Observable들은 일정 기간 동안 계속해서 이벤트를 생성(emit)
 이벤트는 next, error, completed가 있음.
 */

enum Even<Element> {
    case next(Element) // next라는 이벤트는 T에 해당하는 Element를 전달함.
    case error(Swift.Error) // Swift에러를 내뱉으면서, Observable 종료됨.
    case completed // 성공적으로 일련의 이벤트들을 종료시키는 것
}

// Finite Observale
/*
 Element를 방출한 뒤, 성공 또는 에러를 통해 종료되는 Observable
 사용하는 예시
 1. 파일을 다운로드 하는 코드
 2. 시간의 흐름에 따라서 다운로드 시작
 */

// Infinite Observable
/*
 무한한 시퀀스 즉, Observable
 UI 이벤트는 무한한게 관찰할 수 있는 시퀀스
 */

// Hot Observable
/*
 생성되자마자 이벤트를 방출
 나중에 구독한 Observer는 구독 시점의 Observable 중간부분부터 구독할 수 있음.
 여러 Observable들이 동일한 Observable을 구독하면, 동일한 스트림의 이벤트 공유 가능(Multicast)
 Ex) Timer, Subject, UIEvent, Subject 타입 등등
 Subject를 사용하면 Cold Observable를 Hot Observable로 변환할 수 있음.
 */

// Subject 사용 : Cold -> Hot
// ReplaySubject 사용 : Hot -> Cold

// Cold Observable
/*
 Observer가 구독하기 전까지 이벤트를 방출하지 않고 기다림
 처음부터 끝까지의 이벤트 스트림을 볼 수 있음
 여러 Observer들이 동일한 Observerable을 구독하면, 각각 별도의 스트림이 생성되고 할당됨. 즉, 동일한 스트림 이벤트 공유 불가능(Unicast)
 Ex) Single, just, of, HTTP 요청, 데이터베이스 쿼리 등등
 ReplaySubject를 통해 Hot Observable을 Cold Observable 처럼 사용 가능
 */

// Operator
/*
 Observable의 이벤트를 입력받아 결과로 출력해내는 연산자
 다양한 형태로 값을 걸러내거나, 변환하거나, 조합하거나 자기들끼리 합치는 그러한 연산자들이 있음
 주로 비동기 입력을 받아 부수작용 없이 출력만 생성하므로 퍼즐 조각과 같이 쉽게 결합할 수 있음
 표현식이 최종값으로 배출될 때까지 Observable의 방출한 값에 rx의 연산자를 적용하는 것
 */

// Scheduler
/*
 우리가 직접 스케줄러를 생성하거나 커스텀할 일은 거의 없음. Rx의 dispatch queue라고 생각하면 됨, 하지만 훨씬 강력하고 쓰기 쉬움
 Dispatch Queue와 동일함, 하지만 훨씬 쓰기 쉬움
 자신만의 스케줄러를 생성할 일은 거의 없을 것
 */

// MARK: - Observable

// Observable = 일정 기간 동안 계속해서 이벤트를 생성(emit)

// just: 오직 하나의 요소를 포함하는 Observable 시퀀스를 생성
let exampleJust = Observable<Int>.just(1) // 1만 발행

// of: 타입 추론을 통한 Observable 생성
let exampleOfSequence = Observable<Int>.of(1, 2, 3, 4, 5) // 5개의 Int 타입의 element의 이벤트를 생성
let exampleArray = Observable.of([1, 2, 3, 4, 5]) // 1개의 Int 타입의 Array의 이벤트를 생성

// from 오직 array 형태의 element만 받음.
let exampleFrom = Observable.from([1, 2, 3, 4, 5])

// subscribe : Observable이 이벤트들을 방출하도록 해줄 방아쇠 역할
// Observable은 실제로는 시퀀스 정의일 뿐, 즉 Subscribe(구독) 되기 전에는 아무런 이벤트도 내보내지 않음.

// Subscribe method
/*
 Observer가 Observable에 연결하는 것(Observer입장에서 Observable의 emit을 발생하게끔 하는 것)
 (딱 3가지)
 - onNext : Observable의 최신 값을 emit
 - onError : 이벤트 발생 종료 (더 이상 onNext, onCompleted부르지 않음)
 - onCompleted : 정상 종료
 */

// 예제1. Observable.just를 구독
Observable<Int>.just(1).subscribe(onNext: {
    print("Observable.Just의 값은 \($0)")
})

// 예제2. exampleJust 변수 구독
exampleJust.subscribe(onNext: {
    print("exampleJust 값은 \($0)")
})

// 예제3. exampleOfSequence 변수 구독
exampleOfSequence.subscribe(onNext: {
    print("exampleOfSequence 값은 \($0)")
})

// 예제4. exampleArray 변수 구독
exampleArray.subscribe(onNext: {
    print("exampleArray 값은 \($0)")
})

// 예제5. exampleFrom 변수 구독
exampleFrom.subscribe(onNext: {
    print("exampleFrom 값은 \($0)")
})

// empty : 아무런 element를 방출하지 않음, completed 이벤트만 방출
// Observable.empty()

// never : 아무런 이벤트를 방출하지 않음. Completed 이벤트 조차 방출하지 않음.
Observable.never()
    .subscribe(onNext: { print($0) }, onCompleted: { print("Completed") })

// range : start부터 count 크기 만큼의 값을 갖는 Observable을 생성
Observable.of(1, 2, 3, 4, 5, 6, 7, 8, 9).subscribe(onNext: {
    print("2 * \($0) = \(2 * $0)")
})

// dispose : 구독(Subscribe)을 처리, 메모리 누수를 막기위해 사용
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print("\($0)")
    })
    .dispose() // 구독을 dispose

// disposeBag : 구독에 대해서 일일히 관리하는 것은 비효율적이다...
/*
 왜 rxswift DisposeBag을 쓰는가?
 dispose를 사용하지 않으면 등록해놓은 옵져버블이 사라지지 않아서 메모리누수가 발생합니다..
 근데 그걸 일일히 하기 귀찮으니까 disposedBag이라는 가방에 만들어서 뷰가 사라질때 한방에 옵져버블이 다 메모리에서 해제되도록 합니다.
 추가로 subscribe 중이던 disposable을 초기화 하고 싶을 때가 생기기도 하는데 그런 때에는 만들어놓은
 disposeBag 프로퍼티에 새로운 DisposeBag 객체를 할당하면 됩니다.

 - 생성
 var disposeBag = DisposeBag()

 - 모든 옵져버블 초기화
 disposeBag = DisposeBag()
 */
/*
 RxSwift에서 제공하는 disposedBag 타입을 이용
 disposeBag에는 disposables를 가지고 있음.
 disposable은 dispose bag이 할당 해제하려고 할 때마다 dispose()를
 호출.
 */

let disposeBag = DisposeBag()

Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// create : Observable을 만드는 방법 중 하나
/*
 create는 escaping 클로저로, escaping 에서는 AnyObserver를 취한 뒤,
  Disposable을 리턴한다.
 여기서, AnyObserver란 generic 타입으로 Observable sequence에
  값을 쉽게 추가할 수 있다.
 */
// example 1
Observable.create { observer -> Disposable in
    observer.onNext(1)
    observer.on(.next(1))
    observer.onCompleted() // 2가 출력 안 됨.
    observer.onNext(2)
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

// example 2
enum Myerror: Error {
    case anError
}

Observable.create { observer -> Disposable in
    observer.onNext(1)
    observer.onError(Myerror.anError)
    observer.onCompleted()
    observer.onNext(2)
    return Disposables.create()
}
.subscribe(onNext: {
    print($0)
}, onError: {
    print($0.localizedDescription)
}, onCompleted: {
    print("completed")
}, onDisposed: {
    print("disposed")
})

// deferred
// 각 Subscriber에게 새롭게 Observable를 생성해 제공하는 Observable factory(Observable를 감싸는 Observable)

// Deferred of Example
var flip: Bool = false
var count = 0

let factory: Observable<String> = Observable.deferred {
    flip = !flip
    count += 1

    if flip {
        return Observable.of("🤟")
    } else {
        return Observable.of("👌")
    }
}

for _ in 0 ... 6 {
    factory.subscribe(onNext: {
        print($0, count - 1)
    })
    .disposed(by: disposeBag)
}

// Trait
/*
 Single, Maybe, completable
 이전의 Observable 보다는 좁은 범위의 Observable, 선택적으로 사용할 수 있음
 좁은 범위의 Observable를 사용하는 이유는 가독성을 높이는 데 있음.
 */

// Single
/*
 .success(value) 또는 .error 이벤트를 방출
 .success(value) = .next + .completed
  성공 또는 실패로 확인될 수 있는 1회성 프로세스
  정확히 한 가지 요소만을 방출하는 Observable에 적합, asSingle로 변경가능
  */

// Completable
/*
 .completed 또는 .error 만을 방출하며, 이 외 어떠한 값도 방출하지 않는다.
 연산이 제대로 완료되었는지만 확인하고 싶을 때
 asCompleted는 없다.
 Observable이 값 요소를 방출한 이상 completable로 바꿀 수 없다.
 create를 활용해 만들수 밖에 없음, 어떠한 값도 방출하지 않는다.
 */

// Maybe
/*
 Single과 Completable을 섞어 놓은 것
 success(value), .completed, .error를 모두 방출할 수 있다.
 사용 : 프로세스가 성공, 실패 여부와 더불어 출력된 값도 내뱉을 수 있을 때
 */
