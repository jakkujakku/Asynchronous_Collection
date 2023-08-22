import Foundation
import RxSwift

// MARK: - Error Handling

// catch : 에러가 발생했을 때, Error 이벤트로 종료되지 않게 한다.
// Error 이벤트 대신 특정 값의 이벤트를 발생시키고 complete 시킨다.

// catchError
/*
 Error를 다른 타입의 Observable로 반환하는 클로저를 parameter로 받음
 Error가 발생했을 때 Error를 무시하고 클로저의 반환값(Observable<E>)을 반환
 */

let disposeBag = DisposeBag()

let catchErrorobservable = Observable<Int>
    .create { observer -> Disposable in
        observer.onNext(1)
        observer.onNext(2)
        observer.onNext(3)
        observer.onError(NSError(domain: "", code: 100, userInfo: nil))
        observer.onError(NSError(domain: "", code: 200, userInfo: nil))
        return Disposables.create {}
    }

catchErrorobservable
    .catch { .just(($0 as NSError).code) }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// catchErrorJustReturn :Error 가 발생했을 때 Error 를 무시하고 element를 반환, 모든 에러에 동일한 값이 반환되기 때문에 catchError 에 비해 제한적

let catchErrorJustReturnobservable = Observable<Int>
    .create { observer -> Disposable in
        observer.onNext(1)
        observer.onNext(2)
        observer.onNext(3)
        observer.onError(NSError(domain: "", code: 100, userInfo: nil))
        observer.onError(NSError(domain: "", code: 200, userInfo: nil))
        return Disposables.create {}
    }

catchErrorJustReturnobservable
    .catchAndReturn(999)
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// retry : 에러가 발생 했을 때 다시 시도할 수 있게 해줌, 에러가 발생했을 때 Observable 을 다시 시도

// retry() : 에러가 발생했을 때 성공할 때까지 Observable을 다시 시도
let reloadPublisher = PublishSubject<Void>()
// reloadPublisher
//    .flatMap {
//        Api.getRepositories()
//        .retry()
//    }

// retry(_ maxAttemptCount: Int)
/*
 몇 번에 걸쳐서 재시도 할지 지정할 수 있는 연산자
 maxAttemptCount 가 3 이라면 총 3번의 요청을 보냄 (재시도는 2번)
 재시도 횟수가 넘어가면 그대로 Error를 이벤트로 전달
 */
// reloadPublisher
//    .flatMap {
//        Api.getRepositories()
//            .retry(_ maxAttemptCount: Int)
//    }

// retryWhen
/*
 재시도 하는 시점을 지정할 수 있고, 한번만 수행함
 retry 와 다르게 마지막 Error를 이벤트로 전달하지 않음
 */
let time = RxTimeInterval.seconds(0)
let retryWhenObservable = Observable<Int>
    .create { observer -> Disposable in
        observer.onNext(1)
        observer.onNext(2)
        observer.onNext(3)
        observer.onError(NSError(domain: "", code: 100, userInfo: nil))
        observer.onError(NSError(domain: "", code: 200, userInfo: nil))
        return Disposables.create {}
    }

retryWhenObservable
    .retryWhen { _ -> Observable<Int> in
//        .timer(3, scheduler: MainScheduler.instance)
        .timer(RxTimeInterval.seconds(3), scheduler: MainScheduler.instance)
    }
    .subscribe { print($0) }
    .disposed(by: disposeBag)

// RxCocoa : iOS의 Cocoa Framework를 Rx스럽게 사용할 수 있도록 Rx로 감싼 프레임워크 (Cocoa Framework를 wrapping했음)

// ObserverType : 해당 타입에 값을 주입시킬 수 있음
// ObservableType : 해당 타입의 값을 관찰할 수 있음

// Binder
/*
 - ObserverType을 준수함, 따라서 값을 주입할 수는 있으나 관찰할 수는 없음
 -  error 이벤트를 방출할 수 없음
 - RxCocoa에서 binding은 Publisher에서 Subscriber로 향하는 단방향 binding임
 - bind(to:)메소드는 메인스레드 실행을 보장함
 - bind(to: observer)를 호출하게 되면 subscribe(observer)가 실행됨
 - binding 작업을 언제나 메인 스레드에서 실행해주기에, 쓰레드에 대한 관리를 해 줄 필요가 없음
  ex) UILabel+Rx.Swift에서 text Binder 프로퍼티는 값을 주입만 시킬 수 있음
  */

// 변경 전 코드(예시)
// textField.rx.text
//    .observe(on: MainScheduler.instance)
//    .subscribe(onNext: {
//        label.text = $0
//    })
//    .disposed(by: disposeBag)

// 변경 후 코드(예시)
// textField.rx.text
//    .bind(to: label.rx.text)
//    .disposed(by: disposeBag)

// Traits
/*
 - UI처리에 특화된 Observable (UI작업시 코드를 쉽고 직관적으로 작성해 사용할 수 있도록 도와주는 특별한 Observable클래스 모음)
 - error를 방출하지 않음
 - 메인 스케줄러에서 observe or subscribe됨
 - Signal을 제외한 나머지 Traits들은 모든 구독자에 대해 동일한 시퀀스를 공유 (share연산자가 내부적으로 사용된 상태)
  */

// ControlProperty
/*
 - 컨트롤에 data를 binding하기 위해 사용
 - Subject와 같이 프로퍼티에 새 값을 주입시킬 수 있음 (ObserverType), 값의 변화도 관찰할 수 있음(ObservableType)
 - ControlPropertyType을 준수함 (ControlPropertyType은 ObserverType과 ObservableType을 준수함)
 ex) UITextField+Rx.Swift의 text(ControlPropery 프로퍼티)는 프로퍼티에 새값을 주입시킬 수 있고 값의 변화도 관찰할 수 있음
 */

// ControlEvent
/*
 - event(버튼 tap같은)를 Observable로 래핑한 속성
 - Observable의 역할은 수행하지만, ControlProperty와는 다르게 Observer의 역할은 수행하지 못함
 - control이 해제될 경우 Complete이벤트 방출
 - 컨트롤의 event를 수신하기 위해 사용
 */

// 예시 코드
// UIButton+Rx.swift
// extension Reactive where Base: UIButton {
//
//    /// Reactive wrapper for `TouchUpInside` control event.
//    public var tap: ControlEvent<Void> {
//        return controlEvent(.touchUpInside)
//    }
// }

// Driver
/*
 - Observable을 Driver로 바꿔서 사용가능
 - asDriver(onErrorDriverWith:)
 - error를 수동적으로 리턴하여, error에 이벤트를 handle할 수 있음
 - asDriver(onErrorRecover:)
 - driver에 사용되며 error에 대한 이벤트를 handle할 수 있음
 - asDriver(onErrorJustReturn:)
 - Observable에서 error가 방출됐을때 Driver에서 error 대신 지정한 기본 값을 리턴하도록 만들어 Driver에서 error가 방출 되는 것을 막음
  */

// Signal : Driver와 거의 동일하나 자원을 공유하지 않음(Signal은 event모델링에 유용, Driver는 state모델링에 더 적합)

// 예시 코드
// let search = myTextField.rx.text.orEmpty
//    .filter { !$0.imEmpty }
//    .flatMapLatest { text in
//        ApiController.shared.currentWeather(city: text)
//            .catchErrorJustReture(ApiController.Weather.empty)
//    }
//    .asDriver(onErrorJustReturn: ApiController.weather.empty)

/*
  ControlEvent, ControlProperty, Binder

 - getter와 setter를 구현하기에 앞서 ControlEvent, ControlProperty, Binder, Observable 차이를 알기
 - getter만 지원하는 것과 setter만 지원하는 것, 둘 다 지원하는 컴포넌트가 존재
 - getter 전용: controlEvent
 - setter 전용: binder
  */

// 구독하는 메소드 Subscribe, Bind, Drive 차이점
/*
 - Subscribe
 - onNext, onError, onCompleted, onDisposed등을 전부 가지고 있음
 - onError를 통해 에러 처리 가능
 - 쓰레드 지정 가능

 - Bind
 - onNext만 가지고 있음
 - 에러처리가 불가
 - error 또는 completed 이벤트가 발생하지 않고 무한히 이벤트를 방출하는 상황에 쓰임
 - 메인 스레드에서 동작됨

 - Drive
 - onNext, onCompleted, onDisposed을 가지고 있음
 - 에러처리가 불가
 - error 이벤트가 발생하지 않는 상황에 쓰임
 - 메인 스레드에서 동작됨
 - 내부에 share(replay: 1, scope: .whileConnected)가 구현되어 있어, 스트림을 공유함
  */
