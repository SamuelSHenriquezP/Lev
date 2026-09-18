package com.lev.lev

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.lev.lev/widget"
    private var pendingAction: String? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleWidgetIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleWidgetIntent(intent)
        pendingAction?.let { action ->
            methodChannel?.invokeMethod("onWidgetAction", action)
        }
    }

    private fun handleWidgetIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.getStringExtra("action_type")
        if (action != null) {
            pendingAction = action
        } else if (intent.action == LevAppWidgetProvider.ACTION_SOS_RESCUE) {
            pendingAction = "sos_rescue"
        } else if (intent.action == LevAppWidgetProvider.ACTION_HABIT_PAUSE) {
            pendingAction = "habit_pause"
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialAction" -> {
                        val action = pendingAction
                        pendingAction = null
                        result.success(action)
                    }
                    "updateWidget" -> {
                        LevAppWidgetProvider.updateAllWidgets(context)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
        }

        pendingAction?.let { action ->
            methodChannel?.invokeMethod("onWidgetAction", action)
        }
    }
}
