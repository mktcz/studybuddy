package com.studybuddy.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.io.File


class StudyWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.study_widget).apply {
                setTextViewText(
                    R.id.widget_today,
                    widgetData.getString("today", null) ?: "0m",
                )
                setTextViewText(
                    R.id.widget_streak,
                    widgetData.getString("streak", null) ?: "0",
                )

                bindGrid(this, widgetData)
                bindSubjects(context, this, widgetData)


                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun bindGrid(views: RemoteViews, widgetData: SharedPreferences) {
        val path = widgetData.getString("grid", null)
        val bitmap = path
            ?.let { File(it) }
            ?.takeIf { it.exists() }
            ?.let { BitmapFactory.decodeFile(it.absolutePath) }

        if (bitmap == null) {
            views.setViewVisibility(R.id.widget_grid, View.GONE)
        } else {
            views.setViewVisibility(R.id.widget_grid, View.VISIBLE)
            views.setImageViewBitmap(R.id.widget_grid, bitmap)
        }
    }

    private fun bindSubjects(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        val chipIds = intArrayOf(R.id.widget_chip_0, R.id.widget_chip_1, R.id.widget_chip_2)

        chipIds.forEachIndexed { index, chipId ->
            val id = widgetData.getString("subject_${index}_id", null)
            val name = widgetData.getString("subject_${index}_name", null)

            if (id.isNullOrEmpty() || name.isNullOrEmpty()) {
                views.setViewVisibility(chipId, View.GONE)
                return@forEachIndexed
            }

            views.setViewVisibility(chipId, View.VISIBLE)
            views.setTextViewText(chipId, name)

            widgetData.getString("subject_${index}_accent", null)
                ?.takeIf { it.isNotEmpty() }
                ?.let { hex ->
                    runCatching { Color.parseColor(hex) }
                        .onSuccess { views.setTextColor(chipId, it) }
                }


            views.setOnClickPendingIntent(
                chipId,
                HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("studybuddy://start?subject=$id"),
                ),
            )
        }
    }
}
