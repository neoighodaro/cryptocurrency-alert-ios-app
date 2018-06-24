<?php

namespace App\Jobs;

use App\Device;
use Illuminate\Bus\Queueable;
use Illuminate\Queue\SerializesModels;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use App\Events\CurrencyUpdated;
use App\Notifications\CoinPriceChanged;

class CheckPrices implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $supportedCurrencies = ['ETH', 'BTC'];

    /**
     * Execute the job.
     *
     * @return void
     */
    public function handle()
    {
        $timestamp = now()->timestamp;

        $payload = $this->getPricesForSupportedCurrencies();

        if (!empty($payload)) {
            $this->triggerPusherUpdate($payload);
            $this->triggerPossiblePushNotification($payload);
        }

        $this->release();
    }

    private function triggerPusherUpdate($payload)
    {
        event(new CurrencyUpdated($payload));
    }

    private function triggerPossiblePushNotification($payload)
    {
        foreach ($this->supportedCurrencies as $currency) {
            $currentPrice = $payload[$currency]['current'];

            $currency = strtolower($currency);

            foreach (Device::affected($currency, $currentPrice)->get() as $device) {
                $device->notify(new CoinPriceChanged($currency, $device, $payload));
            }
        }
    }

    public function getPricesForSupportedCurrencies(): array
    {
        $payload = [];

        foreach ($this->supportedCurrencies as $currency) {
            if (config('app.debug') === true) {
                $response = [
                    $currency => [
                        'USD' => (float) rand(100, 15000)
                    ]
                ];
            } else {
                $url = "https://min-api.cryptocompare.com/data/pricehistorical?fsym=${currency}&tsyms=USD&ts=${timestamp}";
                $response = json_decode(file_get_contents($url), true);
            }

            if (json_last_error() === JSON_ERROR_NONE) {
                $currentPrice = $response[$currency]['USD'];

                $previousPrice = cache()->get("PRICE_${currency}", false);

                if ($previousPrice == false or $previousPrice !== $currentPrice) {
                    $payload[$currency] = [
                        'current' => $currentPrice,
                        'previous' => $previousPrice,
                    ];
                }

                cache()->put("PRICE_${currency}", $currentPrice, (24 * 60 * 60));
            }
        }

        return $payload;
    }
}
