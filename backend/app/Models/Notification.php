<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Notification extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'type',
        'title',
        'message',
        'channel',
        'status',
        'sent_at',
    ];

    protected $casts = [
        'sent_at' => 'datetime',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isSent(): bool
    {
        return $this->status === 'sent';
    }

    public function isPending(): bool
    {
        return $this->status === 'pending';
    }

    public function isFailed(): bool
    {
        return $this->status === 'failed';
    }

    public function getTypeLabel(): string
    {
        return match($this->type) {
            'payment_reminder' => 'Rappel de paiement',
            'payment_confirmation' => 'Confirmation de paiement',
            'payment_failed' => 'Échec de paiement',
            default => 'Notification'
        };
    }

    public function getChannelLabel(): string
    {
        return match($this->channel) {
            'sms' => 'SMS',
            'push' => 'Push',
            'email' => 'Email',
            default => 'Inconnu'
        };
    }
}
