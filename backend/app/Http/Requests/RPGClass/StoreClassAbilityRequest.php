<?php

namespace App\Http\Requests\RPGClass;

use Illuminate\Foundation\Http\FormRequest;

class StoreClassAbilityRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'O nome da habilidade é obrigatório.',
        ];
    }
}
