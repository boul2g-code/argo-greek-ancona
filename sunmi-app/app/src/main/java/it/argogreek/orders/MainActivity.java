package it.argogreek.orders;

import android.app.Activity;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.Vibrator;
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
    private SunmiPrinterService printer;
    private final InnerPrinterCallback printerCallback = new InnerPrinterCallback() {
        @Override protected void onConnected(SunmiPrinterService service) {
            printer = service;
            runOnUiThread(() -> Toast.makeText(MainActivity.this, "Stampante SUNMI pronta", Toast.LENGTH_SHORT).show());
        }
        @Override protected void onDisconnected() { printer = null; }
    };

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
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
        s.setUserAgentString(s.getUserAgentString()+" ARGO-SUNMI/1.0");
        web.addJavascriptInterface(new ArgoBridge(), "ArgoNative");
        web.setWebViewClient(new WebViewClient());
        web.setWebChromeClient(new WebChromeClient());
        web.loadUrl("https://boul2g-code.github.io/argo-greek-ancona/admin/orders-sunmi.html");
    }

    public class ArgoBridge {
        @JavascriptInterface public void notifyNewOrder() {
            runOnUiThread(() -> {
                try { new ToneGenerator(AudioManager.STREAM_ALARM, 100).startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 900); } catch(Exception ignored) {}
                try { ((Vibrator)getSystemService(VIBRATOR_SERVICE)).vibrate(new long[]{0,350,150,350}, -1); } catch(Exception ignored) {}
                Toast.makeText(MainActivity.this, "ΝΕΑ / NUOVO ORDINE ARGO", Toast.LENGTH_LONG).show();
            });
        }

        @JavascriptInterface public void printTicket(String text) {
            if (printer == null) {
                runOnUiThread(() -> Toast.makeText(MainActivity.this, "Stampante SUNMI non connessa", Toast.LENGTH_LONG).show());
                return;
            }
            new Thread(() -> {
                try {
                    printer.printerInit(null);
                    printer.setAlignment(1, null);
                    printer.setFontSize(28f, null);
                    printer.printText("ARGO GREEK\n", null);
                    printer.setFontSize(22f, null);
                    printer.printText("COMANDA SITO WEB\n\n", null);
                    printer.setAlignment(0, null);
                    printer.setFontSize(24f, null);
                    printer.printText(text + "\n\n\n", null);
                    printer.lineWrap(3, null);
                    runOnUiThread(() -> Toast.makeText(MainActivity.this, "Comanda stampata", Toast.LENGTH_SHORT).show());
                } catch (RemoteException e) {
                    runOnUiThread(() -> Toast.makeText(MainActivity.this, "Errore stampa: "+e.getMessage(), Toast.LENGTH_LONG).show());
                }
            }).start();
        }
    }

    @Override public void onBackPressed() {
        if (web != null && web.canGoBack()) web.goBack(); else super.onBackPressed();
    }

    @Override protected void onDestroy() {
        try { InnerPrinterManager.getInstance().unBindService(this, printerCallback); } catch(Exception ignored) {}
        if (web != null) web.destroy();
        super.onDestroy();
    }
}
