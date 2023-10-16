package com.agmo.dev.gsc.app;

import java.util.*;
import androidx.appcompat.app.AppCompatActivity;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.huawei.agconnect.config.AGConnectServicesConfig;
import com.huawei.agconnect.remoteconfig.AGConnectConfig;
import com.huawei.agconnect.AGConnectOptionsBuilder;
import com.huawei.agconnect.AGConnectInstance;
import com.huawei.agconnect.remoteconfig.ConfigValues;
import com.huawei.hmf.tasks.OnSuccessListener;
import com.huawei.hmf.tasks.OnFailureListener;
import com.huawei.hms.api.ConnectionResult;
import com.huawei.hms.api.HuaweiApiAvailability;

import java.io.*;

import android.os.Bundle;

public class MainActivity extends FlutterActivity {

    private static final int HMS_SERVICES_RESOLUTION_REQUEST = 9001;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

          if (checkHMSServices()) {
            try {
                AGConnectOptionsBuilder builder = new AGConnectOptionsBuilder();
                builder.setInputStream(getAssets().open("agconnect-services.json"));
                AGConnectInstance.initialize(this, builder);
            } catch (IOException e) {
                e.printStackTrace();
            }

            AGConnectServicesConfig config = AGConnectServicesConfig.fromContext(this);
            AGConnectConfig remoteConfig = AGConnectConfig.getInstance();
            remoteConfig.clearAll();
            remoteConfig.fetch().addOnSuccessListener(new OnSuccessListener<ConfigValues>() {
                @Override
                public void onSuccess(ConfigValues configValues) {
                // Apply the parameter values.
                    remoteConfig.apply(configValues); 
                }
            }).addOnFailureListener(new OnFailureListener() {
                @Override
                public void onFailure(Exception e) {
                }
            });

            new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "remote_config_channel")
                .setMethodCallHandler(
                    new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result){
                        if (call.method.equals("getVersion")){
                            System.out.println(">>>>>>>>>> ANDROID GET VERSION");
                        //save result & data as class variable, so it can be accessed in other function
                            Map<String,Object> map = remoteConfig.getMergedAll();
                            result.success(map);
                        } else {
                            result.notImplemented();
                        }
                    }
                }
            );
        } 
    }

     private boolean checkHMSServices() {
        HuaweiApiAvailability apiAvailability = HuaweiApiAvailability.getInstance();
        int resultCode = apiAvailability.isHuaweiMobileServicesAvailable(this);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (apiAvailability.isUserResolvableError(resultCode)) {
                // apiAvailability.getErrorDialog(this, resultCode, HMS_SERVICES_RESOLUTION_REQUEST).show();
            } else {
                // HMS is not available on the device
                // Show an error message or take appropriate action
            }
            return false;
        }
        return true;
    }
}