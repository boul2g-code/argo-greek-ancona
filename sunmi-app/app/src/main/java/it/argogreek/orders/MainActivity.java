package it.argogreek.orders;

import android.app.Activity;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.Vibrator;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import com.sunmi.peripheral.printer.InnerPrinterCallback;
import com.sunmi.peripheral.printer.InnerPrinterManager;
import com.sunmi.peripheral.printer.SunmiPrinterService;

public class MainActivity extends Activity {
    private WebView web;
    private volatile SunmiPrinterService printer;

    private final InnerPrinterCallback printerCallback = new InnerPrinterCallback() {
        @Override protected void onConnected(SunmiPrinterService service) {
            printer = service;
            runOnUiThread(() -> Toast.makeText(MainActivity.this, "Stampante SUNMI pronta", Toast.LENGTH_SHORT).show());
        }

        @Override protected void onDisconnected() {
            printer = null;
            runOnUiThread(() -> Toast.makeText(MainActivity.this, "Stampante SUNMI disconnessa", Toast.LENGTH_LONG).show());
        }
    };

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        try {
            InnerPrinterManager.getInstance().bindService(this, printerCallback);
        } catch (Exception e) {
            Toast.makeText(this, "Connessione stampante SUNMI non disponibile", Toast.LENGTH_LONG).show();
        }

        web = new WebView(this);
        setContentView(web);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setDatabaseEnabled(true);
        s.setCacheMode(WebSettings.LOAD_DEFAULT);
        s.setUserAgentString(s.getUserAgentString() + " ARGO-SUNMI/1.1");
        web.addJavascriptInterface(new ArgoBridge(), "ArgoNative");
        web.setWebViewClient(new WebViewClient());
        web.setWebChromeClient(new WebChromeClient());
        web.loadUrl("https://boul2g-code.github.io/argo-greek-ancona/admin/orders-sunmi.html");
    }

    public class ArgoBridge {
        @JavascriptInterface public boolean isPrinterReady() {
            return printer != null;
        }

        @JavascriptInterface public void notifyNewOrder() {
            runOnUiThread(() -> {
                try {
                    new ToneGenerator(AudioManager.STREAM_ALARM, 100)
                        .startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 900);
                } catch (Exception ignored) {}
                try {
                    ((Vibrator) getSystemService(VIBRATOR_SERVICE))
                        .vibrate(new long[]{0, 350, 150, 350}, -1);
                } catch (Exception ignored) {}
                Toast.makeText(MainActivity.this, "ΝΕΑ / NUOVO ORDINE ARGO", Toast.LENGTH_LONG).show();
            });
        }

        @JavascriptInterface public void printTicket(String text) {
            final SunmiPrinterService currentPrinter = printer;
            if (currentPrinter == null) {
                runOnUiThread(() -> Toast.makeText(MainActivity.this, "Stampante SUNMI non connessa", Toast.LENGTH_LONG).show());
                return;
            }

            new Thread(() -> {
                try {
                    currentPrinter.printerInit(null);
                    currentPrinter.setAlignment(1, null);
                    currentPrinter.setFontSize(28f, null);
                    currentPrinter.printText("ARGO GREEK\n", null);
                    currentPrinter.setFontSize(22f, null);
                    currentPrinter.printText("COMANDA SITO WEB\n\n", null);
                    currentPrinter.setAlignment(0, null);
                    currentPrinter.setFontSize(24f, null);
                    currentPrinter.printText(text + "\n\n\n", null);
                    currentPrinter.lineWrap(3, null);
                    runOnUiThread(() -> Toast.makeText(MainActivity.this, "Comanda stampata", Toast.LENGTH_SHORT).show());
                } catch (RemoteException e) {
                    runOnUiThread(() -> Toast.makeText(MainActivity.this, "Errore stampa: " + e.getMessage(), Toast.LENGTH_LONG).show());
                }
            }).start();
        }
    }

    @Override protected void onResume() {
        super.onResume();
        if (web != null) web.onResume();
    }

    @Override protected void onPause() {
        if (web != null) web.onPause();
        super.onPause();
    }

    @Override public void onBackPressed() {
        if (web != null && web.canGoBack()) web.goBack(); else super.onBackPressed();
    }

    @Override protected void onDestroy() {
        try { InnerPrinterManager.getInstance().unBindService(this, printerCallback); } catch (Exception ignored) {}
        if (web != null) {
            web.loadUrl("about:blank");
            web.stopLoading();
            web.removeAllViews();
            web.destroy();
        }
        super.onDestroy();
    }
}
