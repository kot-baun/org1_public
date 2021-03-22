public class BypassContriller {
	public static Boolean bypassTriger = true;
	public static void enableBypass() {
		bypassTriger = false;
	}
	public static void disableBypass() {
		bypassTriger = true;
	}
}