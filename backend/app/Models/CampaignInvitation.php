<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CampaignInvitation extends Model
{
    use HasFactory;

    protected $table = 'campaign_invitations';

    protected $fillable = [
        'campaign_id',
        'character_id',
        'status',
    ];

    /**
     * Campanha à qual o convite pertence.
     */
    public function campaign(): BelongsTo
    {
        return $this->belongsTo(Campaign::class, 'campaign_id');
    }

    /**
     * Personagem convidado.
     */
    public function character(): BelongsTo
    {
        return $this->belongsTo(Character::class, 'character_id');
    }
}
