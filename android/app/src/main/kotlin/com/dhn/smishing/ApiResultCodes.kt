package com.dhn.smishing

import org.json.JSONObject

/** 서버·Mock 응답 code 정규화 — `1` / `"0001"` / `1.0` 등 */
object ApiResultCodes {
    const val SAFE = "0000"
    const val SMISHING = "0001"

    fun normalize(raw: String?): String {
        val s = raw?.trim()?.trim('"').orEmpty()
        if (s.isEmpty()) return ""
        when (s) {
            "1", "0001", "01" -> return SMISHING
            "0", "0000" -> return SAFE
        }
        s.toIntOrNull()?.let {
            return when (it) {
                1 -> SMISHING
                0 -> SAFE
                else -> s
            }
        }
        return s
    }

    fun isSmishing(code: String): Boolean = normalize(code) == SMISHING

    fun parseFromJson(json: JSONObject): String {
        val raw =
            when {
                json.has("code") && !json.isNull("code") -> json.get("code")
                json.has("result_code") && !json.isNull("result_code") -> json.get("result_code")
                else -> null
            }
        return normalize(raw?.toString())
    }
}
