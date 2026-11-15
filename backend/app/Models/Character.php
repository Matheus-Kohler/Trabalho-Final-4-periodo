<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Character extends Model
{
    use HasFactory;

    protected $table = 'characters';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'rpg_class_id',
        'name',
        'race',
        'level',
        'hp_current',
        'strength',
        'dexterity',
        'constitution',
        'intelligence',
        'wisdom',
        'charisma',
        'gold',
        'history',
        'description',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'level' => 'integer',
            'hp_current' => 'integer',
            'strength' => 'integer',
            'dexterity' => 'integer',
            'constitution' => 'integer',
            'intelligence' => 'integer',
            'wisdom' => 'integer',
            'charisma' => 'integer',
            'gold' => 'decimal:2',
        ];
    }

    /**
     * Usuário (jogador/mestre) dono deste personagem.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Classe do RPG atribuída ao personagem.
     */
    public function rpgClass(): BelongsTo
    {
        return $this->belongsTo(RPGClass::class, 'rpg_class_id');
    }

    /**
     * Campanhas das quais este personagem participa.
     */
    public function campaigns(): BelongsToMany
    {
        return $this->belongsToMany(Campaign::class, 'campaign_character', 'character_id', 'campaign_id')
            ->withPivot('joined_at')
            ->withTimestamps();
    }
}
