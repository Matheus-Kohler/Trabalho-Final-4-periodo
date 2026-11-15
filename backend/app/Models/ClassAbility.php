<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClassAbility extends Model
{
    use HasFactory;

    protected $table = 'class_abilities';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'rpg_class_id',
        'name',
        'description',
    ];

    /**
     * Classe à qual esta habilidade pertence.
     */
    public function rpgClass(): BelongsTo
    {
        return $this->belongsTo(RPGClass::class, 'rpg_class_id');
    }
}
