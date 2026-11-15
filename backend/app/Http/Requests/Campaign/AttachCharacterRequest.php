<?php

namespace App\Http\Requests\Campaign;

use Illuminate\Foundation\Http\FormRequest;

class AttachCharacterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'character_id' => ['required', 'integer', 'exists:characters,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'character_id.required' => 'O ID do personagem é obrigatório.',
            'character_id.exists' => 'O personagem informado não foi encontrado.',
        ];
    }
}
