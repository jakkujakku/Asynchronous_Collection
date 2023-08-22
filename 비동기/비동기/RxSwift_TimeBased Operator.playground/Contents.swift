import Foundation
import RxSwift

// MARK: - TimeBased Operator

let disposeBag = DisposeBag()

// replay : 구독자가 과거의 요소들을 자신이 구독하기 전에 나왔던 이벤트들을 버퍼의 갯수만큼 최신 순서대로 받게 한다.
let 인사말 = PublishSubject<String>()
let 반복하는앵무새 = 인사말.replay(1)
반복하는앵무새.connect()

인사말.onNext("1. hello")
인사말.onNext("2. hi")
반복하는앵무새
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
인사말.onNext("3. 안녕하세요.") // 2. hi 3. 안녕하세요.

// replayAll : 구독자가 과거의 요소들을 자신이 구독하기 전에 나왔던 이벤트들을 무제한으로 받게 한다.

let stranger = PublishSubject<String>()
let timeStone = stranger.replayAll()
timeStone.connect()

stranger.onNext("도르마무")
stranger.onNext("거래를 하러 왔다.")

timeStone
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// buffer : 이벤트를 번들로 한 번에 묶어서 묶음(Array)으로 방출
// timeSpan : 항목을 수집하는 시간
// count : 최대 몇 개까지의 요소를 담을지
// scheduler : 해당 연산자가 실행될 쓰레드를 결정

let source = PublishSubject<String>()

var count = 0
let timer = DispatchSource.makeTimerSource()

timer.schedule(deadline: .now() + 2, repeating: .seconds(1))
timer.setEventHandler {
    count += 1
    source.onNext("\(count)")
}

timer.resume()

source
    .buffer(timeSpan: .seconds(2), count: 2, scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
source.onCompleted()

// window : Buffer와 달리 묶음(Array)이 아닌 Observable 하나씩 방출해줌

let observableCount = 1
let makingTime = RxTimeInterval.seconds(2)

let window = PublishSubject<String>()

var windowCount = 0
let windowTimerSource = DispatchSource.makeTimerSource()
windowTimerSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
windowTimerSource.setEventHandler {
    windowCount += 1
    window.onNext("\(windowCount)")
}

windowTimerSource.resume()

window
    .window(timeSpan: makingTime, count: observableCount, scheduler: MainScheduler.instance)
    .flatMap { windowObservable -> Observable<(index: Int, element: String)> in
        windowObservable.enumerated()
    }
    .subscribe(onNext: {
        print("\($0.index)번째 Observable의 요소 \($0.element)")
    })
    .disposed(by: disposeBag)
window.onCompleted()

// delaySubscription : 구독을 지연하는 연산자

let delaySource = PublishSubject<String>()

var delayCount = 0
let delayTimeSource = DispatchSource.makeTimerSource()
delayTimeSource.schedule(deadline: .now() + 2, repeating: .seconds(1))
delayTimeSource.setEventHandler {
    delayCount += 1
    delaySource.onNext("\(delayCount)")
}

delayTimeSource.resume()

delaySource
    .delaySubscription(.seconds(2), scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
delaySource.onCompleted()

// delay : 시퀀스를 지연하는 연산자

let delaySubject = PublishSubject<Int>()
var delayCount2 = 0
let delayTimerSource2 = DispatchSource.makeTimerSource()
delayTimerSource2.schedule(deadline: .now(), repeating: .seconds(1))
delayTimerSource2.setEventHandler {
    delayCount2 += 1
    delaySubject.onNext(delayCount2)
}

delayTimerSource2.resume()
delaySubject
    .delay(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
delaySubject.onCompleted()

// interval : 지정한 시간에 따라 이벤트를 방출 시켜주는 연산자

Observable<Int>
    .interval(.seconds(3), scheduler: MainScheduler.instance)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// timer : dueTime을 통해 구독을 시작하기까지의 딜레이 값, period는 이벤트가 방출되는 간격

Observable<Int>
    .timer(
        .seconds(5),
        period: .seconds(2),
        scheduler: MainScheduler.instance
    )
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// timeout : dueTime 시간내에 어떠한 이벤트도 방출하지 않았을 때, 에러를 방출함

//let 누르지않으면에러 = UIButton(type: .system)
//누르지않으면에러.setTile("눌러주세요!", for: .normal)
//누르지않으면에러.sizeToFit()
//
//PlaygroundPage.current.liveView = 누르지않으면에러
//
//누르지않으면에러.rx.tap.do(onNext: {
//    print("tap")
//})
//.timeout(.seconds(5), scheduler: MainScheduler.instance)
//.subscribe(onNext: {
//    print($0)
//})
//.disposed(by: disposeBag)
