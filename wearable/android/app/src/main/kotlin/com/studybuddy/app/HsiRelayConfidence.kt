package com.studybuddy.app


object HsiRelayConfidence {
    private val required = listOf("focus", "capacity", "arousal", "stress")

    fun minOfFourAxes(confidences: Map<String, Double>): Double? {
        if (!required.all { confidences.containsKey(it) }) return null
        val values = required.map { confidences.getValue(it) }
        if (values.any { !it.isFinite() || it <= 0.0 }) return 0.0
        return values.minOrNull()
    }
}
