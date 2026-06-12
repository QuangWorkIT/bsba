package com.example.project;

import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import vn.zalopay.sdk.Environment;
import vn.zalopay.sdk.ZaloPayError;
import vn.zalopay.sdk.ZaloPaySDK;
import vn.zalopay.sdk.listeners.PayOrderListener;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "flutter.native/channelPayOrder";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ZaloPaySDK.init(554, Environment.SANDBOX);
    }

    @Override
    public void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        ZaloPaySDK.getInstance().onResult(intent);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("payOrder")) {
                        String token = call.argument("zptoken");
                        ZaloPaySDK.getInstance().payOrder(MainActivity.this, token, "boardnest://payment-result", new PayOrderListener() {
                            @Override
                            public void onPaymentCanceled(String zpTransToken, String appTransID) {
                                result.success("User Canceled");
                            }

                            @Override
                            public void onPaymentError(ZaloPayError zaloPayErrorCode, String zpTransToken, String appTransID) {
                                result.success("Payment failed");
                            }

                            @Override
                            public void onPaymentSucceeded(String transactionId, String transToken, String appTransID) {
                                result.success("Payment Success");
                            }
                        });
                    } else {
                        result.notImplemented();
                    }
                }
            );
    }
}
