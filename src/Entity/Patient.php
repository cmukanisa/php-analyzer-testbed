<?php

declare(strict_types=1);

namespace Testbed\Entity;

use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
class Patient
{
    #[ORM\Id]
    #[ORM\Column(type: 'integer')]
    private int $id = 0;

    #[ORM\Column(type: 'string')]
    private string $email = '';

    public function getId(): int
    {
        return $this->id;
    }

    public function getEmail(): string
    {
        return $this->email;
    }
}
