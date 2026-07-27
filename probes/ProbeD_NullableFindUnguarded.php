<?php

declare(strict_types=1);

namespace Testbed\Probes;

use Doctrine\ORM\EntityManagerInterface;
use Testbed\Entity\Patient;

/**
 * PROBE D — nullable find() result used without a guard.
 * Expected: phpstan=method.nonObject · mago=possible-method-access-on-null.
 */
final class ProbeD_NullableFindUnguarded
{
    public function __construct(private readonly EntityManagerInterface $em)
    {
    }

    public function run(): string
    {
        return $this->em->getRepository(Patient::class)->find(1)->getEmail();
    }
}
