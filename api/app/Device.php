<?php

namespace App;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Notifications\Notifiable;

class Device extends Model
{
    use Notifiable;

    public $timestamps = false;

    protected $fillable = [
        'uuid', 'btc_min_notify', 'btc_max_notify', 'eth_min_notify', 'eth_max_notify'
    ];

    protected $cast = [
        'btc_min_notify' => 'float',
        'btc_max_notify' => 'float',
        'eth_min_notify' => 'float',
        'eth_max_notify' => 'float'
    ];

    public function scopeAffected($query, string $currency, $currentPrice)
    {
        return $query->where(function ($q) use ($currency, $currentPrice) {
            $q->where("${currency}_min_notify", '>', 0)->where("${currency}_min_notify", '>', $currentPrice);
        })->orWhere(function ($q) use ($currency, $currentPrice) {
            $q->where("${currency}_max_notify", '>', 0)->where("${currency}_max_notify", '<', $currentPrice);
        });
    }
}
