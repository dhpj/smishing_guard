package com.dhn.smishing

import java.util.concurrent.atomic.AtomicBoolean

/** 오버레이 「탐지 결과 자세히 보기」→ Flutter 타임라인 화면 */
object OpenTimelineRouter {
    private val pending = AtomicBoolean(false)

    fun requestOpen() {
        pending.set(true)
    }

    fun consume(): Boolean = pending.getAndSet(false)
}
