<?php

declare(strict_types=1);

namespace Testbed\Probes;

use Testbed\Entity\Patient;

/**
 * PROBE E — nonexistent method on an entity.
 * Expected: phpstan=method.notFound · mago=non-existent-method.
 */
final class ProbeE_EntityUnknownMethod
{
    public function run(): mixed
    {
        return (new Patient())->methodThatDoesNotExist();
    }
}
