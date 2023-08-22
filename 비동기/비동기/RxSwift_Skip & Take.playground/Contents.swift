import Foundation
import RxSwift

// MARK: - Skip 시리즈
let disposeBags = DisposeBag()

// skip : 첫 번째 요소를 기준으로 몇 개의 요소를 스킵할 건지에 대한 연산자
let observableSkip = Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
observableSkip
    .skip(5) // 6 이후부터 찍힘.
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags) // 6,7,8

// skipWhile : While 클로전 안의 로직이 true일 때까지 무시하게 됨.
let observableSkipWhile = Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
observableSkipWhile
    .skip(while: {
        $0 != 6 // 6이 되기 전까지 무시함.
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags) // 6, 7, 8

// skipUntil : 이전의 로직은 고정 조건에서 이루어졌지만, 다른 Observable에 기반한 요소들을 다이나믹(=유동적으로) 필터하고 싶으면 skipUntil 사용
let customer = PublishSubject<String>()
let openingTime = PublishSubject<String>()

customer // 현재 Observable
    .skip(until: openingTime) // 다른 Observable
    .subscribe(onNext: {
        print($0)
    })

customer.onNext("1")
customer.onNext("1")

openingTime.onNext("땡!")
// customer이 1을 2번 발행했다.
// openingTime에서 이벤트를 발생하지 않았기 때문에, 기존의 이벤트들은 무시됨.
// openingTime에서 이벤트를 발생한 이후부터 값을 구독함.
customer.onNext("2")

// MARK: - Take 시리즈

// take : 첫번째 요소를 기준으로 몇 개의 요소를 나타날건지에 대한 연산자(skip 연산자와 반대)
let observableTake = Observable.of("1", "2", "3", "4", "5")
observableTake
    // take는 숫자 3까지를 출력하는 것이 아니라, "몇 개의 요소"를 출력함.
    // 무슨 말인지 이해가 되지 않는다면, observableTake의 내부 요소 값을 바꾸거나, 순서를 변경해 보세용~
    .take(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags) // 1, 2, 3 출력

// takeWhile : While 구문 내에서 true 일 때까지 방출하게됨. (skipWhile 연산자와 반대)
// skipWhile : While 클로전 안의 로직이 true일 때까지 무시하게 됨
let observableTakeWhile = Observable.of("1", "2", "3", "4", "5")
observableTakeWhile
    .take(while: {
        $0 != "3" // 3 전까지 출력
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags) // 1, 2 출력

// takeUntil : 이전의 로직은 고정 조건에서 이루어 졌지만, 다른 Observable에 기반한 요소들을 다이나믹하게 필터하고 싶으면 takeUntil 사용
// 기준이 되는 Observable이 이벤트를 나타내기 전까지 요소들을 나타냄

/*
 skipUntil과 takeUntil의 차이점

 skipUntil : 다른 Observable가 이벤트를 발행한 후 이후부터 현재의 Observable가 이벤트를 발행함. (= 다른 Observable가 이벤트를 발생하기 후부터)
 takeUntil : 다른 Observable가 이벤트를 발행한 후 이후부터는 현재의 Observable의 이벤트는 무시됨. (= 다른 Observable가 이벤트를 발생한 전까지)
 */

let applySubject = PublishSubject<String>()
let endApply = PublishSubject<String>()

applySubject // 현재 Observable
    .take(until: endApply) // 다른 Observable
    .subscribe(onNext: {
        print($0)
    })

applySubject.onNext("1")
applySubject.onNext("2") // 여기 까지만 방출함.

endApply.onNext("끝~")
applySubject.onNext("3") // 여기부터는 무시됨.

// distincUntilChanged : 연달아 같은 요소가 이어질 때 중복된 방출을 막아주는 역할
let distincObservable = Observable.of("저는", "저는", "앵무새", "앵무새", "앵무새", "앵무새", "입니다", "입니다", "저는", "앵무새", "일까요")
/*
 현재 배열에 "저는"은 3번 나왔습니다.
 하지만, "저는" 2번 출력이 되었습니다.
 그 이유는 맨 처음 나온 "저는" 과 그 뒤에 나오는 "저는" 일치하면 중복한다고 컴퓨터는 인식하고 무시합니다.
 그러나 3번째로 나오는 "저는"은 뒤에 "앵무새"가 나오기 때문에 정상적으로 출력이 됩니다.
 다른 구문들도 마찬가지입니다. '>'
 */
distincObservable
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0) // 저는 앵무새 입니다 저는 앵무새 일까요 (\n생략)
    })

// enumerated : 방출된 요소의 index를 참고하고 싶을 때 사용
let enumeratedObservable = Observable.of("1", "2", "3", "4", "5")
enumeratedObservable
    .enumerated()
    .take(while: {
        $0.index < 3
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBags)
