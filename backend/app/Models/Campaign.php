<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Campaign extends Model
{
    use HasFactory;

    protected $table = 'campaigns';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'name',
        'description',
        'status',
    ];

    /**
     * Mestre responsável por esta campanha.
     */
    public function master(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    /**
     * Personagens que participam desta campanha.
     */
    public function characters(): BelongsToMany
    {
        return $this->belongsToMany(Character::class, 'campaign_character', 'campaign_id', 'character_id')
            ->withPivot('joined_at')
            ->withTimestamps();
    }

    /**
     * Classes que o mestre disponibilizou para os jogadores desta campanha.
     */
    public function classes(): BelongsToMany
    {
        return $this->belongsToMany(RPGClass::class, 'campaign_class', 'campaign_id', 'rpg_class_id')
            ->withPivot('added_at')
            ->withTimestamps();
    }
}
