<?php

namespace App\Http\Requests\Character;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCharacterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'max:100'],
            'race' => ['sometimes', 'required', 'string', 'max:50'],
            'rpg_class_id' => ['nullable', 'exists:rpg_classes,id'],
            'level' => ['sometimes', 'required', 'integer', 'min:1', 'max:20'],
            'hp_current' => ['sometimes', 'required', 'integer', 'min:0'],
            'strength' => ['sometimes', 'required', 'integer', 'between:1,30'],
            'dexterity' => ['sometimes', 'required', 'integer', 'between:1,30'],
            'constitution' => ['sometimes', 'required', 'integer', 'between:1,30'],
            'intelligence' => ['sometimes', 'required', 'integer', 'between:1,30'],
            'wisdom' => ['sometimes', 'required', 'integer', 'between:1,30'],
            'charisma' => ['sometimes', 'required', 'integer', 'between:1,30'],
            'gold' => ['sometimes', 'required', 'numeric', 'min:0'],
            'history' => ['nullable', 'string'],
            'description' => ['nullable', 'string'],
        ];
    }
}
