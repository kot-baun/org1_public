public class BypassController {
	public static Boolean enableTriger = true;
	public static void enableBypass() {
		enableTriger = false;
	}
	public static void disableBypass() {
		enableTriger = true;
	}
}
