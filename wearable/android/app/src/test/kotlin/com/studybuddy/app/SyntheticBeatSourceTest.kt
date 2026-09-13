package com.studybuddy.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.abs
import kotlin.math.roundToLong

class SyntheticBeatSourceTest {
    @Test
    fun aliasesNormalizeWithoutBreakingCompatNames() {
        assertEquals("rest", SyntheticBeatSource.normalizePreset("calm"))
        assertEquals("stress", SyntheticBeatSource.normalizePreset("stressed"))
        assertEquals("recovery", SyntheticBeatSource.normalizePreset("recover"))
        assertEquals("mixed", SyntheticBeatSource.normalizePreset("mix"))
        assertEquals("focus", SyntheticBeatSource.normalizePreset("focus"))
    }

    @Test
    fun sampleAtIsDeterministicForTheSameBeat() {
        val first = SyntheticBeatSource(preset = "focus", seed = 42).sampleAt(0)
        val again = SyntheticBeatSource(preset = "focus", seed = 42).sampleAt(0)
        assertEquals(first.bpm, again.bpm, 1e-9)
        assertEquals(first.rrIntervalMs, again.rrIntervalMs, 1e-9)
        assertEquals("focus", first.preset)
        assertEquals(42, first.seed)
    }

    @Test
    fun differentSeedsDiverge() {
        val a = SyntheticBeatSource(preset = "focus", seed = 42).sampleAt(7)
        val b = SyntheticBeatSource(preset = "focus", seed = 43).sampleAt(7)
        assertNotEquals(a.rrIntervalMs, b.rrIntervalMs)
    }

    @Test
    fun beatClockAdvancesByRrNotOneHertz() {
        val source = SyntheticBeatSource(preset = "focus", seed = 42)
        val timed = source.timedBeats(8)
        assertTrue(timed.zipWithNext().all { (prev, next) ->
            next.timestampMs - prev.timestampMs == source.delayMs(prev.sample)
        })
        assertNotEquals(1000L, timed[1].timestampMs - timed[0].timestampMs)
    }

    @Test
    fun matchesDartFocusSeed42Vector() {
        val timed = SyntheticBeatSource(preset = "focus", seed = 42).timedBeats(3)
        assertEquals(0L, timed[0].timestampMs)
        assertEquals(830.156450361552, timed[0].sample.rrIntervalMs, 1e-9)
        assertEquals(72.26368496893578, timed[0].sample.bpm, 1e-9)
        assertEquals(830L, timed[1].timestampMs)
        assertEquals(832.711763146003, timed[1].sample.rrIntervalMs, 1e-9)
        assertEquals(1663L, timed[2].timestampMs)
        assertEquals(timed[0].sample.rrIntervalMs.roundToLong(), timed[1].timestampMs)
    }

    @Test
    fun recoveryTransitionsFromStressTowardRest() {
        val recovery = SyntheticBeatSource(preset = "recovery", seed = 42)
        val stress = SyntheticBeatSource(preset = "stress", seed = 42)
        val rest = SyntheticBeatSource(preset = "rest", seed = 42)
        assertEquals(stress.sampleAt(0).rrIntervalMs, recovery.sampleAt(0).rrIntervalMs, 1e-9)
        assertEquals(rest.sampleAt(180).rrIntervalMs, recovery.sampleAt(180).rrIntervalMs, 1e-9)
    }

    @Test
    fun samplesStayBounded() {
        for (preset in listOf("rest", "focus", "stress", "recovery", "mixed")) {
            val source = SyntheticBeatSource(preset = preset, seed = 99)
            repeat(400) { beat ->
                val sample = source.sampleAt(beat)
                assertTrue(sample.bpm in 40.0..180.0)
                assertTrue(sample.rrIntervalMs in 400.0..1600.0)
                val delay = source.delayMs(sample)
                assertTrue(delay in 400L..1600L)
                assertTrue(abs(delay - 1000L) >= 0L)
            }
        }
    }
}
