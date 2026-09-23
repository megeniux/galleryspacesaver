package com.techrigel.rigelspacesaver

import android.content.ContentUris
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Build
import android.os.BatteryManager
import android.os.PowerManager
import android.os.StatFs
import android.os.Environment
import android.provider.MediaStore
import android.media.MediaScannerConnection
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Matrix
import android.net.Uri
import android.media.ExifInterface
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "com.techrigel.rigelspacesaver/system_palette"
        const val MEDIA_CHANNEL = "com.techrigel.rigelspacesaver/media"
        const val MEDIA_PERMISSION_REQUEST = 4017
        const val MEDIA_STORE_CONSENT_REQUEST = 7021
    }

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var pendingPermissionTypes: List<String> = emptyList()
    private var pendingConsentResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSeedColors" -> result.success(readSystemPalette())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "permissionStatus" -> result.success(permissionStatus(emptyList()))
                    "requestPermissions" -> {
                        val types = call.argument<List<String>>("types") ?: emptyList()
                        requestMediaPermissions(types, result)
                    }
                    "scanMedia" -> {
                        val types = call.argument<List<String>>("types") ?: emptyList()
                        val modifiedAfter = call.argument<Long>("modifiedAfter")
                        result.success(scanMedia(types, modifiedAfter))
                    }
                    "thumbnail" -> {
                        val uri = call.argument<String>("uri")
                        val type = call.argument<String>("type")
                        result.success(uri?.let { thumbnail(it, type.orEmpty()) })
                    }
                    "previewCompression" -> {
                        val uri = call.argument<String>("uri")
                        val mime = call.argument<String>("mime") ?: ""
                        val quality = call.argument<Int>("quality") ?: 78
                        val maxDimension = call.argument<Int>("maxDimension") ?: 2048
                        result.success(uri?.let { previewCompression(it, mime, quality, maxDimension) })
                    }
                    "copyMediaToCache" -> {
                        val source = call.argument<String>("source")
                        val targetPath = call.argument<String>("targetPath")
                        if (source == null || targetPath == null) {
                            result.error("INVALID_ARGUMENT", "A source and target are required.", null)
                        } else {
                            result.success(copyMediaToCache(source, targetPath))
                        }
                    }
                    "compressImage" -> {
                        val source = call.argument<String>("source")
                        val outputPath = call.argument<String>("outputPath")
                        val mime = call.argument<String>("mime") ?: ""
                        val quality = call.argument<Int>("quality") ?: 78
                        val maxDimension = call.argument<Int>("maxDimension") ?: 2048
                        if (source == null || outputPath == null) {
                            result.error("INVALID_ARGUMENT", "A source and output are required.", null)
                        } else {
                            result.success(compressImage(source, outputPath, mime, quality, maxDimension))
                        }
                    }
                    "processingGuards" -> result.success(processingGuards())
                    "storageInfo" -> result.success(storageInfo())
                    "startProcessingService" -> {
                        ContextCompat.startForegroundService(this, Intent(this, ProcessingService::class.java))
                        result.success(null)
                    }
                    "stopProcessingService" -> {
                        stopService(Intent(this, ProcessingService::class.java))
                        result.success(null)
                    }
                    "requestMediaStoreConsent" -> {
                        val uri = call.argument<String>("uri")
                        val action = call.argument<String>("action")
                        if (uri == null || action == null) {
                            result.error("INVALID_ARGUMENT", "A URI and action are required.", null)
                        } else {
                            requestMediaStoreConsent(uri, action, result)
                        }
                    }
                    "writeCachedFileToUri" -> {
                        writeCachedFileToUri(call.argument<String>("sourcePath"), call.argument<String>("uri"))
                        result.success(null)
                    }
                    "deleteMediaUri" -> {
                        val uri = call.argument<String>("uri") ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "A URI is required.", null)
                        contentResolver.delete(android.net.Uri.parse(uri), null, null)
                        result.success(null)
                    }
                    "rescanMedia" -> {
                        val path = call.argument<String>("path")
                        if (path != null && !path.startsWith("content://")) {
                            MediaScannerConnection.scanFile(this, arrayOf(path), null, null)
                        }
                        result.success(null)
                    }
                    "openAppSettings" -> {
                        startActivity(Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                        })
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != MEDIA_PERMISSION_REQUEST) return
        getPreferences(MODE_PRIVATE).edit().putBoolean("media_permissions_requested", true).apply()
        pendingPermissionResult?.success(permissionStatus(pendingPermissionTypes))
        pendingPermissionResult = null
        pendingPermissionTypes = emptyList()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == MEDIA_STORE_CONSENT_REQUEST) {
            pendingConsentResult?.success(resultCode == RESULT_OK)
            pendingConsentResult = null
        }
    }

    private fun requestMediaStoreConsent(uriString: String, action: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            result.success(true)
            return
        }
        val uri = android.net.Uri.parse(uriString)
        val sender = when (action) {
            "write" -> MediaStore.createWriteRequest(contentResolver, listOf(uri)).intentSender
            "delete" -> MediaStore.createDeleteRequest(contentResolver, listOf(uri)).intentSender
            else -> null
        }
        if (sender == null) {
            result.success(false)
            return
        }
        pendingConsentResult = result
        startIntentSenderForResult(sender, MEDIA_STORE_CONSENT_REQUEST, null, 0, 0, 0)
    }

    private fun requestMediaPermissions(types: List<String>, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.success(permissionStatus(types))
            return
        }
        val permissions = permissionsFor(types)
        val missing = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isEmpty()) {
            result.success(permissionStatus(types))
            return
        }
        pendingPermissionResult = result
        pendingPermissionTypes = types
        ActivityCompat.requestPermissions(this, missing.toTypedArray(), MEDIA_PERMISSION_REQUEST)
    }

    private fun permissionsFor(types: List<String>): List<String> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            return listOf("android.permission.READ_EXTERNAL_STORAGE")
        }
        val permissions = types.mapNotNull {
            when (it) {
                "image" -> "android.permission.READ_MEDIA_IMAGES"
                "video" -> "android.permission.READ_MEDIA_VIDEO"
                "audio" -> "android.permission.READ_MEDIA_AUDIO"
                else -> null
            }
        }.toMutableSet()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
            types.any { it == "image" || it == "video" }
        ) {
            permissions += "android.permission.READ_MEDIA_VISUAL_USER_SELECTED"
        }
        return permissions.toList()
    }

    private fun permissionStatus(types: List<String>): Map<String, Any> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            return mapOf("state" to "granted", "partial" to false)
        }
        val requested = getPreferences(MODE_PRIVATE).getBoolean("media_permissions_requested", false)
        val permissions = permissionsFor(if (types.isEmpty()) listOf("image", "video", "audio") else types)
        val granted = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) == PackageManager.PERMISSION_GRANTED
        }.toSet()
        val visualSelected = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            "android.permission.READ_MEDIA_VISUAL_USER_SELECTED" in granted
        } else {
            false
        }
        val requestedMedia = permissions.filterNot {
            it == "android.permission.READ_MEDIA_VISUAL_USER_SELECTED"
        }
        val allMediaGranted = requestedMedia.all { it in granted }
        val anyMediaGranted = requestedMedia.any { it in granted }
        val state = when {
            allMediaGranted -> "granted"
            visualSelected || anyMediaGranted -> "partial"
            !requested -> "undetermined"
            permissions.any {
                it !in granted && !ActivityCompat.shouldShowRequestPermissionRationale(this, it)
            } -> "permanentlyDenied"
            else -> "denied"
        }
        return mapOf(
            "state" to state,
            "partial" to (state == "partial"),
            // True when Android only gave us user-selected visual media, so the
            // UI can offer a "select more photos and videos" action.
            "visualUserSelected" to visualSelected,
            "grantedTypes" to listOf("image", "video", "audio").filter { canReadType(it) },
        )
    }

    /**
     * Whether this media type is readable right now. Under Android 14 partial
     * access the per-type permission is denied but READ_MEDIA_VISUAL_USER_SELECTED
     * still exposes the photos *and* videos the user picked.
     */
    private fun canReadType(type: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return true
        val permission = permissionsFor(listOf(type)).firstOrNull { !it.endsWith("VISUAL_USER_SELECTED") }
        val primaryGranted = permission == null ||
            ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
        if (primaryGranted) return true
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE &&
            (type == "image" || type == "video") &&
            ContextCompat.checkSelfPermission(
                this,
                "android.permission.READ_MEDIA_VISUAL_USER_SELECTED",
            ) == PackageManager.PERMISSION_GRANTED
    }

    private fun scanMedia(types: List<String>, modifiedAfter: Long?): List<Map<String, Any?>> {
        // Scan every type we are allowed to read. Previously a single denied
        // type (typically audio, which partial access never covers) made the
        // whole scan return nothing, so photos and videos disappeared too.
        val readable = types.filter { canReadType(it) }
        if (readable.isEmpty()) return emptyList()

        val rows = mutableListOf<Map<String, Any?>>()
        for (type in readable) {
            val (collection, mediaType) = when (type) {
                "image" -> MediaStore.Images.Media.EXTERNAL_CONTENT_URI to MediaStore.Files.FileColumns.MEDIA_TYPE_IMAGE
                "video" -> MediaStore.Video.Media.EXTERNAL_CONTENT_URI to MediaStore.Files.FileColumns.MEDIA_TYPE_VIDEO
                "audio" -> MediaStore.Audio.Media.EXTERNAL_CONTENT_URI to MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO
                else -> continue
            }
            val projection = mutableListOf(
                MediaStore.MediaColumns._ID,
                MediaStore.MediaColumns.DATA,
                MediaStore.MediaColumns.DISPLAY_NAME,
                MediaStore.MediaColumns.SIZE,
                MediaStore.MediaColumns.DATE_MODIFIED,
                MediaStore.MediaColumns.MIME_TYPE,
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                projection += MediaStore.MediaColumns.WIDTH
                projection += MediaStore.MediaColumns.HEIGHT
            }
            if (type == "video") projection += MediaStore.Video.VideoColumns.DURATION
            val selection = if (modifiedAfter != null) "${MediaStore.MediaColumns.DATE_MODIFIED} > ?" else null
            val args = modifiedAfter?.let { arrayOf((it / 1000).toString()) }
            contentResolver.query(collection, projection.toTypedArray(), selection, args, "${MediaStore.MediaColumns.DATE_MODIFIED} DESC")
                ?.use { cursor ->
                    val idIndex = cursor.getColumnIndex(MediaStore.MediaColumns._ID)
                    val pathIndex = cursor.getColumnIndex(MediaStore.MediaColumns.DATA)
                    val nameIndex = cursor.getColumnIndex(MediaStore.MediaColumns.DISPLAY_NAME)
                    val sizeIndex = cursor.getColumnIndex(MediaStore.MediaColumns.SIZE)
                    val modifiedIndex = cursor.getColumnIndex(MediaStore.MediaColumns.DATE_MODIFIED)
                    val mimeIndex = cursor.getColumnIndex(MediaStore.MediaColumns.MIME_TYPE)
                    val widthIndex = cursor.getColumnIndex(MediaStore.MediaColumns.WIDTH)
                    val heightIndex = cursor.getColumnIndex(MediaStore.MediaColumns.HEIGHT)
                    val durationIndex = cursor.getColumnIndex(MediaStore.Video.VideoColumns.DURATION)
                    while (cursor.moveToNext()) {
                        val id = cursor.getLong(idIndex)
                        val uri = ContentUris.withAppendedId(collection, id).toString()
                        rows += mapOf(
                            "path" to (pathIndex.takeIf { it >= 0 }?.let { cursor.getString(it) } ?: uri),
                            "uri" to uri,
                            "type" to type,
                            "size" to cursor.getLong(sizeIndex),
                            "dateMillis" to (modifiedIndex.takeIf { it >= 0 }?.let { cursor.getLong(it) * 1000 } ?: 0),
                            "width" to widthIndex.takeIf { it >= 0 }?.let { cursor.getInt(it) },
                            "height" to heightIndex.takeIf { it >= 0 }?.let { cursor.getInt(it) },
                            "durationMs" to durationIndex.takeIf { it >= 0 }?.let { cursor.getLong(it) },
                            "mime" to mimeIndex.takeIf { it >= 0 }?.let { cursor.getString(it) },
                            "name" to (nameIndex.takeIf { it >= 0 }?.let { cursor.getString(it) } ?: uri.substringAfterLast('/')),
                            "mediaType" to mediaType,
                        )
                    }
                }
        }
        return rows
    }

    private fun thumbnail(uriString: String, type: String): ByteArray? {
        return try {
            val uri = android.net.Uri.parse(uriString)
            val bitmap: Bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentResolver.loadThumbnail(uri, android.util.Size(480, 480), null)
            } else {
                val id = ContentUris.parseId(uri)
                when (type) {
                    "image" -> MediaStore.Images.Thumbnails.getThumbnail(contentResolver, id, MediaStore.Images.Thumbnails.MINI_KIND, null)
                    "video" -> MediaStore.Video.Thumbnails.getThumbnail(contentResolver, id, MediaStore.Video.Thumbnails.MINI_KIND, null)
                    else -> null
                }
            } ?: return null
            ByteArrayOutputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 82, output)
                output.toByteArray()
            }
        } catch (_: Exception) {
            // A media item can disappear between the scan and thumbnail request.
            null
        }
    }

    /**
     * Returns the wallpaper-derived Material You accent colors, or null when the
     * platform predates Android 12 and exposes no system palette.
     */
    private fun readSystemPalette(): Map<String, Int>? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return null
        return try {
            mapOf(
                "accent1" to getColor(android.R.color.system_accent1_500),
                "accent2" to getColor(android.R.color.system_accent2_500),
                "accent3" to getColor(android.R.color.system_accent3_500),
                "neutral1" to getColor(android.R.color.system_neutral1_500),
            )
        } catch (_: Exception) {
            // Some OEM builds omit these resources; fall back to the brand
            // palette rather than failing to theme the app at all.
            null
        }
    }

    private fun previewCompression(
        uriString: String,
        mime: String,
        quality: Int,
        maxDimension: Int,
    ): ByteArray? {
        if (mime !in setOf("image/jpeg", "image/png", "image/webp")) return null
        return try {
            val source = contentResolver.openInputStream(android.net.Uri.parse(uriString)) ?: return null
            val decoded = source.use { BitmapFactory.decodeStream(it) } ?: return null
            val oriented = applyExifOrientation(decoded, readExifOrientation(uriString))
            val largest = maxOf(oriented.width, oriented.height)
            val bitmap = if (largest > maxDimension) {
                val scale = maxDimension.toFloat() / largest
                Bitmap.createScaledBitmap(
                    oriented,
                    (oriented.width * scale).toInt().coerceAtLeast(1),
                    (oriented.height * scale).toInt().coerceAtLeast(1),
                    true,
                )
            } else {
                oriented
            }
            val format = when (mime) {
                "image/png" -> Bitmap.CompressFormat.PNG
                "image/webp" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    Bitmap.CompressFormat.WEBP_LOSSY
                } else {
                    @Suppress("DEPRECATION")
                    Bitmap.CompressFormat.WEBP
                }
                else -> Bitmap.CompressFormat.JPEG
            }
            ByteArrayOutputStream().use { output ->
                bitmap.compress(format, quality.coerceIn(1, 100), output)
                if (bitmap !== oriented) bitmap.recycle()
                if (oriented !== decoded && oriented.isRecycled.not()) oriented.recycle()
                if (decoded.isRecycled.not()) decoded.recycle()
                output.toByteArray()
            }
        } catch (_: Exception) {
            // Preview is best-effort and must never make the library scan fail.
            null
        }
    }

    private fun copyMediaToCache(source: String, targetPath: String): String {
        val target = File(targetPath)
        target.parentFile?.mkdirs()
        val input = if (source.startsWith("content://")) {
            contentResolver.openInputStream(android.net.Uri.parse(source))
        } else {
            FileInputStream(File(source))
        } ?: throw IllegalStateException("Media source could not be opened.")
        input.use { stream ->
            FileOutputStream(target).use { output -> stream.copyTo(output) }
        }
        return target.absolutePath
    }

    private fun compressImage(
        source: String,
        outputPath: String,
        mime: String,
        quality: Int,
        maxDimension: Int,
    ): String {
        val input = if (source.startsWith("content://")) {
            contentResolver.openInputStream(android.net.Uri.parse(source))
        } else {
            FileInputStream(File(source))
        } ?: throw IllegalStateException("Image source could not be opened.")
        val decoded = input.use { BitmapFactory.decodeStream(it) }
            ?: throw IllegalStateException("Image could not be decoded.")
        val oriented = applyExifOrientation(decoded, readExifOrientation(source))
        val largest = maxOf(oriented.width, oriented.height)
        val bitmap = if (largest > maxDimension) {
            val scale = maxDimension.toFloat() / largest
            Bitmap.createScaledBitmap(
                oriented,
                (oriented.width * scale).toInt().coerceAtLeast(1),
                (oriented.height * scale).toInt().coerceAtLeast(1),
                true,
            )
        } else oriented
        val format = when {
            mime == "image/png" -> Bitmap.CompressFormat.PNG
            mime == "image/webp" -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                Bitmap.CompressFormat.WEBP_LOSSY
            } else {
                @Suppress("DEPRECATION")
                Bitmap.CompressFormat.WEBP
            }
            else -> Bitmap.CompressFormat.JPEG
        }
        val output = File(outputPath)
        output.parentFile?.mkdirs()
        FileOutputStream(output).use { stream ->
            if (!bitmap.compress(format, quality.coerceIn(1, 100), stream)) {
                throw IllegalStateException("Image encoder rejected the output format.")
            }
        }
        if (bitmap !== oriented) bitmap.recycle()
        if (oriented !== decoded && oriented.isRecycled.not()) oriented.recycle()
        decoded.recycle()
        return output.absolutePath
    }

    private fun readExifOrientation(source: String): Int {
        return try {
            if (source.startsWith("content://")) {
                contentResolver.openInputStream(Uri.parse(source))?.use { input ->
                    ExifInterface(input).getAttributeInt(
                        ExifInterface.TAG_ORIENTATION,
                        ExifInterface.ORIENTATION_NORMAL,
                    )
                } ?: ExifInterface.ORIENTATION_NORMAL
            } else {
                ExifInterface(source).getAttributeInt(
                    ExifInterface.TAG_ORIENTATION,
                    ExifInterface.ORIENTATION_NORMAL,
                )
            }
        } catch (_: Exception) {
            // Missing or malformed EXIF must leave the original pixel matrix unchanged.
            ExifInterface.ORIENTATION_NORMAL
        }
    }

    private fun applyExifOrientation(bitmap: Bitmap, orientation: Int): Bitmap {
        val matrix = Matrix()
        when (orientation) {
            ExifInterface.ORIENTATION_FLIP_HORIZONTAL -> matrix.setScale(-1f, 1f)
            ExifInterface.ORIENTATION_ROTATE_180 -> matrix.setRotate(180f)
            ExifInterface.ORIENTATION_FLIP_VERTICAL -> {
                matrix.setRotate(180f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_TRANSPOSE -> {
                matrix.setRotate(90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_90 -> matrix.setRotate(90f)
            ExifInterface.ORIENTATION_TRANSVERSE -> {
                matrix.setRotate(-90f)
                matrix.postScale(-1f, 1f)
            }
            ExifInterface.ORIENTATION_ROTATE_270 -> matrix.setRotate(-90f)
            else -> return bitmap
        }
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    private fun processingGuards(): Map<String, Any> {
        val battery = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = battery?.getIntExtra(BatteryManager.EXTRA_LEVEL, 100) ?: 100
        val scale = battery?.getIntExtra(BatteryManager.EXTRA_SCALE, 100) ?: 100
        val status = battery?.getIntExtra(BatteryManager.EXTRA_STATUS, BatteryManager.BATTERY_STATUS_UNKNOWN)
            ?: BatteryManager.BATTERY_STATUS_UNKNOWN
        val thermal = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            (getSystemService(POWER_SERVICE) as PowerManager).currentThermalStatus
        } else 0
        val stats = StatFs(cacheDir.path)
        return mapOf(
            "batteryPercent" to if (scale > 0) level * 100 / scale else 100,
            "charging" to (status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL),
            "thermalStatus" to thermal,
            "freeBytes" to stats.availableBytes,
        )
    }

    private fun storageInfo(): Map<String, Long> {
        val stats = StatFs(Environment.getDataDirectory().path)
        return mapOf(
            "totalBytes" to stats.totalBytes,
            "freeBytes" to stats.availableBytes,
        )
    }

    private fun writeCachedFileToUri(sourcePath: String?, uriString: String?) {
        if (sourcePath == null || uriString == null) throw IllegalArgumentException("A source and URI are required.")
        val input = FileInputStream(File(sourcePath))
        val output = contentResolver.openOutputStream(android.net.Uri.parse(uriString), "w")
            ?: throw IllegalStateException("MediaStore did not open the destination for writing.")
        input.use { source -> output.use { destination -> source.copyTo(destination) } }
    }
}
