<?php

declare(strict_types=1);

namespace Testbed\Probes;

use Doctrine\ORM\EntityManagerInterface;
use Testbed\Entity\Patient;

/**
 * PROBE B — unknown persisted field in findOneBy criteria.
 * Measured: phpstan=doctrine.findOneByArgument · mago=SILENT (Doctrine plugin stage 1 target).
 */
final class ProbeB_DoctrineUnknownField
{
    public function __construct(private readonly EntityManagerInterface $em)
    {
    }

    public function run(): ?Patient
    {
        return $this->em->getRepository(Patient::class)->findOneBy(['fieldThatDoesNotExist' => 'x']);
    }
}
