<?php

declare(strict_types=1);

namespace Testbed\Service;

interface GradeLookup
{
    public function gradeForUser(int $userId): ?string;
}
