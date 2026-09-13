package com.studybuddy.app

import kotlin.math.roundToLong


class SyntheticBeatSource(
    preset: String = "focus",
    var seed: Int = 42,
) {
    var preset: String = normalizePreset(preset)
        set(value) {
            field = normalizePreset(value)
        }

    @Deprecated("Use preset")
    var scenario: String
        get() = preset
        set(value) {
            preset = value
        }

    fun sampleAt(beat: Int): BeatSample {
        val params = paramsAt(beat)
        val u1 = unit(seed.toLong() + beat.toLong() * 9973L)
        val walk = unit(seed.toLong() + beat.toLong() * 7919L) * 2.0 - 1.0
        val rr = (params.baseRrMs +
            params.ampMs * sinApprox(beat / 12.0) +
            (u1 * 2.0 - 1.0) * params.jitterMs +
            walk * 12.0)
            .coerceIn(400.0, 1600.0)
        val observation = (unit(seed.toLong() + beat.toLong() * 4243L) * 2.0 - 1.0) * 0.15
        val bpm = (60000.0 / rr + observation).coerceIn(40.0, 180.0)
        return BeatSample(
            bpm = bpm,
            rrIntervalMs = rr,
            accuracy = "medium",
            preset = preset,
            seed = seed,
            beatIndex = beat,
        )
    }

    fun delayMs(sample: BeatSample): Long =
        sample.rrIntervalMs.roundToLong().coerceIn(400L, 1_600L)

    fun timedBeats(count: Int, startMs: Long = 0L): List<TimedBeat> {
        var timestampMs = startMs
        return List(count) { beat ->
            val sample = sampleAt(beat)
            val timed = TimedBeat(timestampMs = timestampMs, sample = sample)
            timestampMs += delayMs(sample)
            timed
        }
    }

    data class BeatSample(
        val bpm: Double,
        val rrIntervalMs: Double,
        val accuracy: String,
        val preset: String = "focus",
        val seed: Int = 42,
        val beatIndex: Int = 0,
    )

    data class TimedBeat(
        val timestampMs: Long,
        val sample: BeatSample,
    )

    private data class Params(val baseRrMs: Double, val ampMs: Double, val jitterMs: Double)

    private val rest = Params(1034.0, 70.0, 48.0)
    private val focus = Params(833.0, 48.0, 24.0)
    private val stress = Params(638.0, 14.0, 6.0)

    private fun paramsAt(beat: Int): Params = when (preset) {
        "rest" -> rest
        "stress" -> stress
        "recovery" -> lerp(stress, rest, (beat / 180.0).coerceIn(0.0, 1.0))
        "mixed" -> mixedAt(beat)
        else -> focus
    }

    private fun mixedAt(beat: Int): Params {
        val cycle = beat % 240
        return when {
            cycle < 90 -> focus
            cycle < 120 -> lerp(focus, stress, (cycle - 90) / 30.0)
            cycle < 210 -> stress
            else -> lerp(stress, focus, (cycle - 210) / 30.0)
        }
    }

    private fun lerp(a: Params, b: Params, t: Double): Params {
        val w = t.coerceIn(0.0, 1.0)
        return Params(
            a.baseRrMs + (b.baseRrMs - a.baseRrMs) * w,
            a.ampMs + (b.ampMs - a.ampMs) * w,
            a.jitterMs + (b.jitterMs - a.jitterMs) * w,
        )
    }

    private fun sinApprox(turns: Double): Double {
        val tau = 6.283185307179586
        var x = (turns * tau) % tau
        if (x > 3.141592653589793) x -= tau
        val x2 = x * x
        return x * (1 - x2 / 6 + x2 * x2 / 120)
    }

    private fun unit(value: Long): Double {
        var x = value xor 0x5DEECE66D
        x = (x * 1103515245L + 12345L) and 0x7fffffff
        return x.toDouble() / 0x7fffffff
    }

    companion object {
        fun normalizePreset(raw: String): String = when (raw.trim().lowercase()) {
            "rest", "calm" -> "rest"
            "stress", "stressed" -> "stress"
            "recovery", "recover" -> "recovery"
            "mixed", "mix" -> "mixed"
            else -> "focus"
        }
    }
}
