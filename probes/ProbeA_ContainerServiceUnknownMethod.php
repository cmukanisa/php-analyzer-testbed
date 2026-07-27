<?php

declare(strict_types=1);

namespace Testbed\Probes;

use Psr\Container\ContainerInterface;
use Testbed\Service\GradeLookup;

/**
 * PROBE A — nonexistent method on a container-fetched service (::class idiom).
 * Expected: phpstan=method.notFound · mago(+psr-container)=non-existent-method.
 */
final class ProbeA_ContainerServiceUnknownMethod
{
    public function __construct(private readonly ContainerInterface $container)
    {
    }

    public function run(): mixed
    {
        $lookup = $this->container->get(GradeLookup::class);

        return $lookup->methodThatDoesNotExist();
    }
}
