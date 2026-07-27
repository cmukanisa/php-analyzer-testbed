<?php

declare(strict_types=1);

namespace Testbed\Probes;

use Doctrine\ORM\EntityManagerInterface;
use Testbed\Entity\Patient;

/**
 * PROBE G — magic finder on an unknown field (the mago-symfony issue #1 gap).
 * Measured: phpstan=method.notFound · mago=non-documented-method warning only, no field validation (Doctrine plugin stage 2 target).
 */
final class ProbeG_MagicFinderUnknownField
{
    public function __construct(private readonly EntityManagerInterface $em)
    {
    }

    public function run(): mixed
    {
        return $this->em->getRepository(Patient::class)->findOneByFieldThatDoesNotExist('x');
    }
}
