<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Group extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'type',
        'contribution_amount',
        'frequency',
        'payment_mode',
        'next_due_date',
        'is_active',
    ];

    protected $casts = [
        'contribution_amount' => 'decimal:2',
        'next_due_date' => 'date',
        'is_active' => 'boolean',
    ];

    public function members(): HasMany
    {
        return $this->hasMany(GroupMember::class);
    }

    public function contributions(): HasMany
    {
        return $this->hasMany(Contribution::class);
    }

    public function activeMembers()
    {
        return $this->members()->where('is_active', true);
    }

    public function admins()
    {
        return $this->members()->where('role', 'admin');
    }
}
