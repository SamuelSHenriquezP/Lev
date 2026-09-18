package com.lev.lev

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

class LevAppWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        const val ACTION_SOS_RESCUE = "com.lev.lev.ACTION_SOS_RESCUE"
        const val ACTION_HABIT_PAUSE = "com.lev.lev.ACTION_HABIT_PAUSE"
        private const val PREFS_NAME = "FlutterSharedPreferences"

        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.lev_app_widget)

            // Leer datos guardados por Flutter en SharedPreferences
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val userName = prefs.getString("flutter.lev_user_name", "") ?: ""
            val careDrops: Long = try {
                prefs.getLong("flutter.lev_care_drops", -1L)
            } catch (_: Exception) {
                try {
                    prefs.getInt("flutter.lev_care_drops", -1).toLong()
                } catch (_: Exception) {
                    -1L
                }
            }
            val customDialogue = prefs.getString("flutter.lev_widget_dialogue", "") ?: ""

            val dropsText = if (careDrops >= 0) "💧 $careDrops" else "🌱 Lev"
            views.setTextViewText(R.id.widget_drops, dropsText)

            val quote = when {
                customDialogue.isNotBlank() -> customDialogue
                userName.isNotBlank() && userName != "Humano" -> "Respira hondo, $userName... todo está bien."
                else -> "Respira hondo... estás a salvo aquí."
            }
            views.setTextViewText(R.id.widget_quote, quote)

            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

            // Click en el fondo general abre la app
            val mainIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            val mainPendingIntent = PendingIntent.getActivity(context, 0, mainIntent, pendingIntentFlags)
            views.setOnClickPendingIntent(R.id.widget_root, mainPendingIntent)

            // Click en SOS Ansiedad abre la app con acción especial
            val sosIntent = Intent(context, MainActivity::class.java).apply {
                action = ACTION_SOS_RESCUE
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra("action_type", "sos_rescue")
            }
            val sosPendingIntent = PendingIntent.getActivity(context, 1, sosIntent, pendingIntentFlags)
            views.setOnClickPendingIntent(R.id.widget_btn_sos, sosPendingIntent)

            // Click en Pausa 60s abre la app con acción de pausa
            val pauseIntent = Intent(context, MainActivity::class.java).apply {
                action = ACTION_HABIT_PAUSE
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra("action_type", "habit_pause")
            }
            val pausePendingIntent = PendingIntent.getActivity(context, 2, pauseIntent, pendingIntentFlags)
            views.setOnClickPendingIntent(R.id.widget_btn_pause, pausePendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, LevAppWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            for (id in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, id)
            }
        }
    }
}
