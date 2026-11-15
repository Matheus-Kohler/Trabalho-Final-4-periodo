<?php

namespace App\Http\Requests\RPGClass;

use Illuminate\Foundation\Http\FormRequest;

class UpdateRPGClassRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'hp_base' => ['sometimes', 'required', 'integer', 'min:1'],
            'gold_initial' => ['sometimes', 'required', 'numeric', 'min:0'],
        ];
    }
}
