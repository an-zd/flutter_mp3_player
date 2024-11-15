package com.example.mp3_player

import android.media.audiofx.Visualizer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class AudioVisualizerPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private var visualizer: Visualizer? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "audio_visualizer")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "startVisualizer" -> {
                val sessionId = call.argument<Int>("sessionId")
                if (sessionId != null) {
                    startVisualizer(sessionId)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Session ID is required", null)
                }
            }
            "stopVisualizer" -> {
                stopVisualizer()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startVisualizer(sessionId: Int) {
        visualizer = Visualizer(sessionId).apply {
            captureSize = Visualizer.getCaptureSizeRange()[1]
            scalingMode = Visualizer.SCALING_MODE_NORMALIZED
            measurementMode = Visualizer.MEASUREMENT_MODE_NONE
            setDataCaptureListener(object : Visualizer.OnDataCaptureListener {
                override fun onWaveFormDataCapture(visualizer: Visualizer?, waveform: ByteArray?, samplingRate: Int) {
                    // We're not using waveform data in this example
                }

                override fun onFftDataCapture(visualizer: Visualizer?, fft: ByteArray?, samplingRate: Int) {
                    fft?.let {
                        val magnitudes = FloatArray(it.size / 2)
                        for (i in 0 until magnitudes.size) {
                            val re = it[2 * i].toInt() and 0xFF
                            val im = it[2 * i + 1].toInt() and 0xFF
                            magnitudes[i] = Math.sqrt((re * re + im * im).toDouble()).toFloat()
                        }
                        channel.invokeMethod("updateFrequencies", magnitudes.toList())
                    }
                }
            }, Visualizer.getMaxCaptureRate() / 2, false, true)
            enabled = true
        }
    }

    private fun stopVisualizer() {
        visualizer?.enabled = false
        visualizer?.release()
        visualizer = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}