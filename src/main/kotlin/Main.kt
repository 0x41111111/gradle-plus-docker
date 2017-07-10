import com.google.gson.Gson

/**
 * A simple main class.
 */
class Main {
    companion object {
        @JvmStatic fun main(args: Array<String>) {
            println("Yay, everything built properly!")
            println("External dependencies work too:")
            val gson = Gson()
            val output = gson.toJson(mapOf("hello" to "world"))
            println(output)
        }
    }
}
