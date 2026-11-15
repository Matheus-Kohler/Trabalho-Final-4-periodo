<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class RPGClass extends Model
{
    use HasFactory;

    protected $table = 'rpg_classes';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'name',
        'description',
        'hp_base',
        'gold_initial',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'hp_base' => 'integer',
            'gold_initial' => 'decimal:2',
        ];
    }

    /**
     * Usuário criador da classe.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Habilidades associadas a esta classe.
     */
    public function abilities(): HasMany
    {
        return $this->hasMany(ClassAbility::class, 'rpg_class_id');
    }

    /**
     * Personagens que utilizam esta classe.
     */
    public function characters(): HasMany
    {
        return $this->hasMany(Character::class, 'rpg_class_id');
    }

    /**
     * Campanhas em que esta classe foi disponibilizada pelo mestre.
     */
    public function campaigns(): BelongsToMany
    {
        return $this->belongsToMany(Campaign::class, 'campaign_class', 'rpg_class_id', 'campaign_id')
            ->withPivot('added_at')
            ->withTimestamps();
    }
}
