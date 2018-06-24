<?php

use App\Setting;
use Illuminate\Http\Request;

Route::get('/settings', function (Request $request) {
    return Setting::whereDeviceUuid($request->query('u'))->firstOrFail()['settings'];
});

Route::post('/settings', function (Request $request) {
    $settings = $request->validate([
        'btc_min_notify' => 'int|min:0',
        'btc_max_notify' => 'int|min:0',
        'eth_min_notify' => 'int|min:0',
        'eth_max_notify' => 'int|min:0',
    ]);

    // Remove all entries with values less than or equal to zero
    $settings = array_filter($settings, function ($value) { return $value > 0; });

    $device = Setting::firstOrNew(['device_uuid' => $request->query('u')]);
    $device->fill($settings);
    $saved = $device->save();

    return response()->json([
        'status' => $saved ? 'success' : 'failure'
    ], $saved ? 200 : 400);
});
