<?php

namespace App\Http\Resources;

use App\Models\ReportAttachment;
use App\Support\Label;
use Illuminate\Http\Request;

/** @mixin ReportAttachment */
class ReportAttachmentResource extends ApiResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'type' => ['value' => $this->type, 'label' => Label::humanize($this->type)],
            'mime_type' => $this->mime_type,
            'is_image' => $this->isImage(),
            'size_kb' => $this->size_kb,
            'url' => route('api.v1.media', ['type' => 'attachment', 'id' => $this->id]),
            'created_at' => $this->date($this->created_at),
        ];
    }
}
