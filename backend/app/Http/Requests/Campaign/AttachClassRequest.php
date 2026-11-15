<?php

namespace App\Http\Requests\Campaign;

use Illuminate\Foundation\Http\FormRequest;

class AttachClassRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'rpg_class_id' => ['required', 'integer', 'exists:rpg_classes,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'rpg_class_id.required' => 'O ID da classe é obrigatório.',
            'rpg_class_id.exists' => 'A classe informada não foi encontrada.',
        ];
    }
}
