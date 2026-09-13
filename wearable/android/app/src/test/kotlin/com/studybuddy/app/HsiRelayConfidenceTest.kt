package com.studybuddy.app

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class HsiRelayConfidenceTest {
    @Test
    fun missingAxisIsNotAFourAxisWindow() {
        assertNull(
            HsiRelayConfidence.minOfFourAxes(
                mapOf(
                    "focus" to 0.8,
                    "capacity" to 0.7,
                    "arousal" to 0.6,
                ),
            ),
        )
    }

    @Test
    fun zeroConfidenceIsNotPositive() {
        assertEquals(
            0.0,
            HsiRelayConfidence.minOfFourAxes(
                mapOf(
                    "focus" to 0.0,
                    "capacity" to 0.5,
                    "arousal" to 0.5,
                    "stress" to 0.0,
                ),
            )!!,
            0.0,
        )
    }

    @Test
    fun allPositiveReturnsTheMinimum() {
        assertEquals(
            0.41,
            HsiRelayConfidence.minOfFourAxes(
                mapOf(
                    "focus" to 0.8,
                    "capacity" to 0.41,
                    "arousal" to 0.6,
                    "stress" to 0.55,
                ),
            )!!,
            1e-9,
        )
    }
}
