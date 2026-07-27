<?php

declare(strict_types=1);

namespace Testbed\Service;

final class StaticGradeLookup implements GradeLookup
{
    public function gradeForUser(int $userId): ?string
    {
        return $userId > 0 ? 'default' : null;
    }
}
