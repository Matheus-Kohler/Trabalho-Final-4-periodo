<?php

namespace App\Http\Requests\RPGClass;

use Illuminate\Foundation\Http\FormRequest;

class StoreRPGClassRequest extends FormRequest
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
            'hp_base' => ['nullable', 'integer', 'min:1'],
            'gold_initial' => ['nullable', 'numeric', 'min:0'],
            'abilities' => ['nullable', 'array'],
            'abilities.*.name' => ['required_with:abilities', 'string', 'max:100'],
            'abilities.*.description' => ['nullable', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'O nome da classe é obrigatório.',
            'hp_base.integer' => 'O HP base deve ser um número inteiro.',
            'gold_initial.numeric' => 'O ouro inicial deve ser um valor numérico.',
        ];
    }
}
