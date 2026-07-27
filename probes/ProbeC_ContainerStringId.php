<?php

declare(strict_types=1);

namespace Testbed\Probes;

use Psr\Container\ContainerInterface;

/**
 * PROBE C — nonexistent method on a service fetched by STRING id.
 * Measured: phpstan(+containerXmlPath)=method.notFound · mago=mixed-method-access (blind — Symfony plugin target).
 */
final class ProbeC_ContainerStringId
{
    public function __construct(private readonly ContainerInterface $container)
    {
    }

    public function run(): mixed
    {
        $lookup = $this->container->get('testbed.grade_lookup');

        return $lookup->methodThatDoesNotExist();
    }
}
