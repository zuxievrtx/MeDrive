<?php

namespace App\Http\Requests\Api\V1\Chat;

use App\Http\Requests\Api\V1\ApiFormRequest;
use App\Models\ChatMessage;
use Illuminate\Validation\Rule;

/**
 * JSON {type: text, body} atau multipart {type: image, image}. Aplikasi mengompres foto (~300 KB) sebelum kirim.
 */
class SendChatMessageRequest extends ApiFormRequest
{
    /**
     * @return array<string, array<int, mixed>>
     */
    public function rules(): array
    {
        return [
            'type' => ['required', Rule::in([ChatMessage::TYPE_TEXT, ChatMessage::TYPE_IMAGE])],
            'body' => ['required_if:type,text', 'prohibited_if:type,image', 'nullable', 'string', 'max:1000'],
            'image' => ['required_if:type,image', 'prohibited_if:type,text', 'nullable', 'image', 'mimes:jpg,jpeg,png', 'max:'.(int) config('medrive.chat.image_max_kb')],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function attributes(): array
    {
        return ['type' => 'jenis pesan', 'body' => 'isi pesan', 'image' => 'foto'];
    }
}
