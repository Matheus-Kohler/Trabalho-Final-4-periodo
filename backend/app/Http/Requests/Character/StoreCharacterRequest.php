<?php

namespace App\Http\Requests\Character;

use Illuminate\Foundation\Http\FormRequest;

class StoreCharacterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'race' => ['required', 'string', 'max:50'],
            'rpg_class_id' => ['nullable', 'exists:rpg_classes,id'],
            'level' => ['nullable', 'integer', 'min:1', 'max:20'],
            'hp_current' => ['nullable', 'integer', 'min:0'],
            'strength' => ['nullable', 'integer', 'between:1,30'],
            'dexterity' => ['nullable', 'integer', 'between:1,30'],
            'constitution' => ['nullable', 'integer', 'between:1,30'],
            'intelligence' => ['nullable', 'integer', 'between:1,30'],
            'wisdom' => ['nullable', 'integer', 'between:1,30'],
            'charisma' => ['nullable', 'integer', 'between:1,30'],
            'gold' => ['nullable', 'numeric', 'min:0'],
            'history' => ['nullable', 'string'],
            'description' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'O nome do personagem é obrigatório.',
            'race.required' => 'A raça do personagem é obrigatória.',
            'rpg_class_id.exists' => 'A classe selecionada não foi encontrada.',
        ];
    }
}
