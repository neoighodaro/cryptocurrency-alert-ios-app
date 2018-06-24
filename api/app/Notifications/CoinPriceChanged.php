<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Neo\PusherBeams\PusherBeams;
use Neo\PusherBeams\PusherMessage;
use App\Device;

class CoinPriceChanged extends Notification
{
    use Queueable;

    private $currency;
    private $device;
    private $payload;

    /**
     * Create a new notification instance.
     *
     * @return void
     */
    public function __construct(string $currency, Device $device, array $payload)
    {
        $this->currency = $currency;
        $this->device = $device;
        $this->payload = $payload;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return [PusherBeams::class];
    }

    public function toPushNotification($notifiable)
    {
        $currentPrice = $this->payload[strtoupper($this->currency)]['current'];
        $previousPrice = $this->payload[strtoupper($this->currency)]['current'];

        $direction = $currentPrice > $previousPrice ? 'climbed' : 'dropped';

        $currentPriceFormatted = number_format($currentPrice);

        return PusherMessage::create()
                ->iOS()
                ->sound('success')
                ->title("Price of {$this->currency} has {$direction}")
                ->body("The price of {$this->currency} has {$direction} and is now \${$currentPriceFormatted}");
    }

    public function pushNotificationInterest()
    {
        return "{$this->device->uuid}_{$this->currency}_changed";
    }
}
