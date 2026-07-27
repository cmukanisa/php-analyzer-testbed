<?php

declare(strict_types=1);

namespace Testbed\Probes;

/**
 * PROBE F — int returned where string is declared.
 * Expected: phpstan=return.type · mago=invalid-return-statement.
 */
final class ProbeF_WrongReturnType
{
    public function run(): string
    {
        return 42;
    }
}
