package com.midea.light.device.explore.controller.utils;

public final class Utils {

    private static final char[] hexArray = "0123456789abcdef".toCharArray();

    private Utils() {
    }

    /**
     * Waits util a condition is met.
     *
     * <p>This is often used to wait for asynchronous operations to finish and the system to reach a
     * desired state.
     *
     * <p>If the predicate function throws an exception and interrupts the waiting, the exception
     * will be wrapped in an {@link RuntimeException}.
     *
     * @param predicate A lambda function that specifies the condition to wait for. This function
     *                  should return true when the desired state has been reached.
     * @param timeout   The number of seconds to wait for before giving up.
     * @return true if the operation finished before timeout, false otherwise.
     */
    public static boolean waitUntil(Predicate predicate, int timeout) {
        timeout *= 10;
        try {
            while (!predicate.waitCondition() && timeout >= 0) {
                Thread.sleep(100);
                timeout -= 1;
            }
            if (predicate.waitCondition()) {
                return true;
            }
        } catch (Throwable e) {
            throw new RuntimeException(e);
        }
        return false;
    }

    public static void tryAndRun(Function function) {
        try {
            function.run();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @FunctionalInterface
    public interface Function {
        void run() throws Exception;
    }

    /**
     * A function interface that is used by lambda functions signaling an async operation is still
     * going on.
     */
    public interface Predicate {
        boolean waitCondition() throws Throwable;
    }

    /**
     * Convert a byte array (binary data) to a hexadecimal string (ASCII) representation.
     *
     * <p>[\x01\x02] -&gt; "0102"
     *
     * @param bytes The array of byte to convert.
     * @return a String with the ASCII hex representation.
     */
    public static String bytesToHexString(byte[] bytes) {
        char[] hexChars = new char[bytes.length * 2];
        for (int j = 0; j < bytes.length; j++) {
            int v = bytes[j] & 0xFF;
            hexChars[j * 2] = hexArray[v >>> 4];
            hexChars[j * 2 + 1] = hexArray[v & 0x0F];
        }
        return new String(hexChars);
    }
}